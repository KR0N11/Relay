import SwiftUI

struct PromptCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let questions: [String]
}

enum SheetContext: Identifiable {
    case selectPrompt
    case editPrompt(Prompt)
    
    var id: String {
        switch self {
        case .selectPrompt:
            return "select"
        case .editPrompt(let prompt):
            return prompt.id
        }
    }
}

struct CandidateHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var resumeURL: String = ""
    @State private var coverLetterURL: String = ""
    @State private var prompts: [Prompt] = []
    
    @State private var sheetContext: SheetContext? = nil
    
    let promptBank: [PromptCategory] = [
        PromptCategory(name: "Projects & Skills", questions: [
            "My proudest project is...",
            "A skill I taught myself is...",
            "The tech stack I find most exciting is...",
            "Something I built that I'm proud of is...",
            "The most complex problem I've solved..."
        ]),
        PromptCategory(name: "Passion & Personality", questions: [
            "I'm passionate about this field because...",
            "I geek out on...",
            "A non-work-related fact about me is...",
            "My ideal team environment is..."
        ]),
        PromptCategory(name: "Career & Goals", questions: [
            "I'm looking for a company that values...",
            "In five years, I want to be...",
            "The best career advice I've received...",
            "A company's mission I admire is..."
        ])
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("My Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // --- Basic Info Section ---
                VStack(alignment: .leading) {
                    Text("My Info")
                        .font(.headline)
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Phone (Optional)", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // --- Documents Section ---
                VStack(alignment: .leading) {
                    Text("My Documents")
                        .font(.headline)
                    TextField("Resume URL", text: $resumeURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Cover Letter URL (Optional)", text: $coverLetterURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // --- Prompts Section (Hinge-Style) ---
                VStack(alignment: .leading) {
                    Text("My Prompts")
                        .font(.headline)
                    
                    ForEach(prompts) { prompt in
                        PromptCard(prompt: prompt) {
                            self.sheetContext = .editPrompt(prompt)
                        }
                    }
                    
                    if prompts.count < 3 {
                        AddPromptButton {
                            self.sheetContext = .selectPrompt
                        }
                    }
                }
                
                Spacer()
                
                // --- Save Button ---
                Button(action: saveProfile) {
                    Text(authViewModel.isLoading ? "Saving..." : "Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(authViewModel.isLoading)
            }
            .padding()
        }
        .onAppear(perform: loadProfileData)
        .sheet(item: $sheetContext) { context in
            switch context {
                
            case .selectPrompt:
                PromptSelectionView(promptBank: promptBank, onSelect: { question in
                    let newPrompt = Prompt(question: question, answer: "")
                    self.prompts.append(newPrompt)
                    self.sheetContext = .editPrompt(newPrompt)
                })
                
            case .editPrompt(let prompt):
                if let index = self.prompts.firstIndex(where: { $0.id == prompt.id }) {
                    
                    PromptEditorView(
                        prompt: $prompts[index],
                        onSave: {
                            self.sheetContext = nil // just close
                        },
                        onDelete: {
                            self.prompts.remove(at: index) // remove from list
                            self.sheetContext = nil // close
                        }
                    )
                }
            }
        }
    }
    
    //Helper Functions
    
    func loadProfileData() {
        if let profile = authViewModel.candidateProfile {
            self.name = profile.name
            self.phone = profile.phone
            self.resumeURL = profile.resumeURL
            self.coverLetterURL = profile.coverLetterURL
            self.prompts = profile.prompts
        }
    }
    
    func saveProfile() {
        if var profile = authViewModel.candidateProfile {
            profile.name = name
            profile.phone = phone
            profile.resumeURL = resumeURL
            profile.coverLetterURL = coverLetterURL
            profile.prompts = prompts
            
            Task {
                await authViewModel.updateCandidateProfile(profile)
            }
        }
    }
}

//Helper UI Views

struct AddPromptButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Add a prompt...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct PromptCard: View {
    var prompt: Prompt
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(prompt.question)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(prompt.answer.isEmpty ? "Tap to add..." : prompt.answer)
                    .font(.callout)
                    .foregroundStyle(prompt.answer.isEmpty ? .secondary : .primary)
                    .lineLimit(3)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct PromptQuestionView: View {
    let category: PromptCategory
    var onSelect: (String) -> Void
    
    var body: some View {
        List(category.questions, id: \.self) { question in
            Button(action: {
                onSelect(question)
            }) {
                Text(question)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .listStyle(.inset)
        .navigationTitle(category.name)
    }
}

struct PromptSelectionView: View {
    let promptBank: [PromptCategory]
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                Text("Select a Prompt")
                    .font(.headline)
                    .padding()

                List(promptBank) { category in
                    NavigationLink(value: category) {
                        Text(category.name)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                }
                .listStyle(.inset)
            }
            .navigationDestination(for: PromptCategory.self) { category in
                PromptQuestionView(category: category, onSelect: onSelect)
            }
        }
        .background(Color(.systemBackground))
    }
}


struct PromptEditorView: View {
    @Binding var prompt: Prompt
    var onSave: () -> Void
    var onDelete: () -> Void // new delete action
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            // header
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save") { onSave() }
            }
            .padding([.top, .horizontal])
            
            Text("Edit Prompt")
                .font(.headline)
                .padding(.bottom)

            // editor
            Text(prompt.question)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            TextEditor(text: $prompt.answer)
                .frame(height: 200)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal)
            
            Spacer()
            
            Button("Delete Prompt", role: .destructive) {
                onDelete()
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}


#Preview("CandidateHomeView") {
    CandidateHomeView()
        .environmentObject(AuthViewModel())
}

#Preview("PromptSelectionView") {
    let previewBank: [PromptCategory] = [
        PromptCategory(name: "Projects & Skills", questions: ["q1", "q2"]),
        PromptCategory(name: "Passion & Personality", questions: ["q3", "q4"]),
        PromptCategory(name: "Career & Goals", questions: ["q5", "q6"])
    ]
    return PromptSelectionView(
        promptBank: previewBank,
        onSelect: { _ in }
    )
}

#Preview("PromptEditorView") {
    PromptEditorView(
        prompt: .constant(Prompt(question: "My proudest project is...", answer: "I built this app!")),
        onSave: { },
        onDelete: { } // add delete to preview
    )
}
