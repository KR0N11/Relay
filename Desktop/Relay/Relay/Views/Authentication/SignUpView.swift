//
//  SignUpView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct SignUpView: View {

    var role: UserAccount.UserRole
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Create \(role == .candidate ? "Candidate" : "Recruiter") Account")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)
            
            TextField("Full Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            //loading spinner if the view model is busy
            if authViewModel.isLoading {
                ProgressView()
                    .padding(.top)
            } else {
                Button(action: {
                    Task {
                        await authViewModel.signUp(
                            email: email,
                            password: password,
                            name: name,
                            role: role
                        )
                    }
                }) {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            
            //error message if one exists
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            Spacer() 
        }
        .padding()
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUpView(role: .candidate)
            .environmentObject(AuthViewModel())
    }
}
