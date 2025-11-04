//
//  JoinEventView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct JoinEventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        VStack {
            Text("Join Event")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("This is where you'll enter the recruiter's code.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    JoinEventView()
        .environmentObject(AuthViewModel())
}
