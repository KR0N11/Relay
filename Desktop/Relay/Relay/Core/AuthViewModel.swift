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
    
    // @Published properties will automatically update any SwiftUI views observing this class
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserAccount? // Our custom user profile from Firestore
    
    @Published var isLoading = false
    @Published var errorMessage = ""

    private var db = Firestore.firestore()

    init() {
        // Check if a user was already logged in when the app launched
        self.userSession = Auth.auth().currentUser
        
        // Asynchronously fetch their profile data if they exist
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
            //Create the user in Firebase Auth
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            self.userSession = authResult.user

            //Create our custom UserAccount profile in Firestore
            let newUser = UserAccount(id: uid, email: email, name: name, userRole: role)
            let userData = newUser.dictionary
            let userAccountRef = db.collection("users").document(uid)
            
            let batch = db.batch()
            batch.setData(userData, forDocument: userAccountRef)

            //Create the specific role profile (Candidate or Recruiter)
            if role == .candidate {
                let newCandidate = Candidate(id: uid, name: name)
                let candidateRef = db.collection("candidates").document(uid)
                batch.setData(newCandidate.dictionary, forDocument: candidateRef)
                
            } else if role == .recruiter {
                // todo: Update companyID from a placeholder
                let newRecruiter = Recruiter(id: uid, name: name, email: email, companyID: "NEEDS_COMPANY_ID")
                let recruiterRef = db.collection("recruiters").document(uid)
                batch.setData(newRecruiter.dictionary, forDocument: recruiterRef)
            }
            
            //Commit the batch to save all data to Firestore
            try await batch.commit()
            
            //Update the app's state with the new user data
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
            // Clear all local user data
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out: \(error.localizedDescription)")
        }
    }

    func fetchCurrentUser() async {
        guard let uid = userSession?.uid else { return } // Ensure a user is logged in
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                print("DEBUG: User document was empty.")
                return
            }
            
            self.currentUser = UserAccount(id: snapshot.documentID, dictionary: data)
            
            print("DEBUG: Current user fetched: \(self.currentUser?.name ?? "N/A")")
            
        } catch {
            print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
        }
    }
}
