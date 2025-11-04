//
//  AuthViewModel.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import Foundation
import Combine // Required for @Published and ObservableObject
import FirebaseAuth
import FirebaseFirestore

@MainActor // Ensures UI updates are always on the main thread
class AuthViewModel: ObservableObject {
    
    // @Published properties will automatically update any SwiftUI views
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserAccount? // The main user account
    @Published var candidateProfile: Candidate? // The detailed candidate profile
    
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var db = Firestore.firestore()

    init() {
        // Check if user was already logged in
        self.userSession = Auth.auth().currentUser

        Task {
            await fetchCurrentUser()
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user
            await fetchCurrentUser() // Load their profile data after login
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to sign in: \(error.localizedDescription)")
        }
        
        isLoading = false
    }

    func signUp(email: String, password: String, name: String, role: UserAccount.UserRole) async {
        isLoading = true
        errorMessage = ""
        
        do {
            // 1. Create the user in Firebase Auth
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            self.userSession = authResult.user

            // 2. Create our custom UserAccount profile
            let newUser = UserAccount(id: uid, email: email, name: name, userRole: role)
            let userData = newUser.dictionary
            let userAccountRef = db.collection("users").document(uid)
            
            // Use a 'batch write' to save all documents at once
            let batch = db.batch()
            batch.setData(userData, forDocument: userAccountRef)

            // 3. Create the specific role profile
            if role == .candidate {
                let newCandidate = Candidate(id: uid, name: name)
                let candidateRef = db.collection("candidates").document(uid)
                batch.setData(newCandidate.dictionary, forDocument: candidateRef)
                
                self.candidateProfile = newCandidate
                
            } else if role == .recruiter {
                let newRecruiter = Recruiter(id: uid, name: name, email: email, companyID: "NEEDS_COMPANY_ID")
                let recruiterRef = db.collection("recruiters").document(uid)
                batch.setData(newRecruiter.dictionary, forDocument: recruiterRef)
            }
            
            // 4. Commit the batch to save all data
            try await batch.commit()
            
            // 5. Update the app's state
            self.currentUser = newUser
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to sign up: \(error.localizedDescription)")
        }
        
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.candidateProfile = nil
        } catch {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }

    func fetchCurrentUser() async {
        guard let uid = userSession?.uid else { return }
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                print("DEBUG: User document was empty.")
                return
            }
            
            let user = UserAccount(id: snapshot.documentID, dictionary: data)
            self.currentUser = user
            
            if user?.userRole == .candidate {
                await fetchCandidateProfile(uid: uid)
            }
            
            print("DEBUG: Current user fetched: \(self.currentUser?.name ?? "N/A")")
            
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    func fetchCandidateProfile(uid: String) async {
        do {
            let snapshot = try await db.collection("candidates").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                print("DEBUG: Candidate profile was empty.")
                return
            }
            
            self.candidateProfile = Candidate(id: snapshot.documentID, dictionary: data)
            print("DEBUG: Fetched candidate profile for \(self.candidateProfile?.name ?? "")")
            
        } catch {
            print("DEBUG: Failed to fetch candidate profile: \(error.localizedDescription)")
        }
    }
    
    func updateCandidateProfile(_ profile: Candidate) async {

        let uid = profile.id

        isLoading = true
        do {
            let data = profile.dictionary
            try await db.collection("candidates").document(uid).setData(data, merge: true)
            
            self.candidateProfile = profile
            print("DEBUG: Candidate profile updated.")
        } catch {
            self.errorMessage = error.localizedDescription
            print("DEBUG: Failed to update profile: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
