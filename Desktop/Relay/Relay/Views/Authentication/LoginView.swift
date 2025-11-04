//
//  LoginView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome Back")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if authViewModel.isLoading {
                ProgressView()
                    .padding(.top)
            } else {
                Button(action: {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }
                }) {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Log In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
