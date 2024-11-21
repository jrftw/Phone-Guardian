//
//  GoldTabView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/20/24.
//


import SwiftUI

struct GoldTabView: View {
    var body: some View {
        List {
            Section(header: Text("Gold Features")) {
                NavigationLink("Test Kit", destination: TestKitView())
                NavigationLink("Export Reports to PDF", destination: ReportsView())
                NavigationLink("Notification Kit", destination: NotificationsView()) // Placeholder
                NavigationLink("Virus Scanner", destination: VirusScannerView())
                NavigationLink("Clean Duplicates", destination: UnlockPromptView(feature: "Clean Duplicates"))
                NavigationLink("Deep Clean RAM", destination: UnlockPromptView(feature: "Deep Clean RAM"))
            }
        }
        .navigationTitle("Gold Features")
        .listStyle(InsetGroupedListStyle())
    }
}

// Unlock Prompt for Restricted Features
struct UnlockPromptView: View {
    let feature: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Unlock \(feature)")
                .font(.title)
                .bold()

            Text("This feature is available for Gold members only. Purchase Gold to unlock!")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                // Trigger purchase logic
            }) {
                Text("Purchase Gold")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}