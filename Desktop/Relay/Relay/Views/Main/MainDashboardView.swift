//
//  MainDashboardView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if let user = authViewModel.currentUser {
                    // We have the user's profile
                    switch user.userRole {
                    case .candidate:
                        CandidateHomeView()
                    case .recruiter:
                        RecruiterHomeView()
                    }
                } else {
                    // User is logged in
                    ProgressView()
                }
            }
            .navigationTitle("Relay")
            .navigationBarItems(trailing: Button("Sign Out") {
                authViewModel.signOut()
            })
        }
    }
}

#Preview {
    MainDashboardView()
        .environmentObject(AuthViewModel())
}
