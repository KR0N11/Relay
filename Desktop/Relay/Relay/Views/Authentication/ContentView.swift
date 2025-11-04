//
//  ContentView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.userSession == nil {
                // User is NOT logged in
                RoleSelectionView()
            } else {
                // User IS logged in
                MainDashboardView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
