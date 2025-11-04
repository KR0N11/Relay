//
//  CandidateHomeView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//

import SwiftUI

struct CandidateHomeView: View {
    var body: some View {
        VStack {
            Text("Welcome, Candidate!")
                .font(.title)
            Text("Your dashboard will go here.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    CandidateHomeView()
}
