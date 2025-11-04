//
//  MainTabView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

        var body: some View {
            TabView {
                
                // Tab 1: Profile
                NavigationStack {
                    CandidateHomeView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                
                // Tab 2: Join Event
                NavigationStack {
                    JoinEventView()
                }
                .tabItem {
                    Label("Join Event", systemImage: "qrcode.viewfinder")
                }
            }
        }
    }

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
