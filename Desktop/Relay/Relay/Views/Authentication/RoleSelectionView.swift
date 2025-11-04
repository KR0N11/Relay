//
//  RoleSelectionView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // PLACEHOLDER FOR IMAGE
                Spacer()
                
                Text("Welcome to Relay")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Find your next opportunity or your next great hire.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(value: UserAccount.UserRole.candidate) {
                    Text("I'm a Candidate")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity) // Full-width button
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(value: UserAccount.UserRole.recruiter) {
                    Text("I'm a Recruiter")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5)) // A different style
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                Spacer().frame(height: 20)
                
                // A separate link to the LoginView
                NavigationLink("Already have an account? Log In",
                               destination: LoginView())
                .font(.footnote)
                
            }
            .padding()
            // This tells the NavigationStack which view to open
            // when it receives a 'UserAccount.UserRole' value
            .navigationDestination(for: UserAccount.UserRole.self) { role in
                SignUpView(role: role)
            }
        }
    }
}

#Preview {
    RoleSelectionView()
}
