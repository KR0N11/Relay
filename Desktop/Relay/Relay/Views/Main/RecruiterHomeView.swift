//
//  RecruiterHomeView.swift
//  Relay
//
//  Created by user286649 on 11/4/25.
//
import SwiftUI

struct RecruiterHomeView: View {
    var body: some View {
        VStack {
            Text("Welcome, Recruiter!")
                .font(.title)
            Text("Your event and candidate dashboard will go here.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RecruiterHomeView()
}
