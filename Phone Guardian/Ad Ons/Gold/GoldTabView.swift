// GoldTabView.swift

import SwiftUI

struct GoldTabView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Gold Features")) {
                    NavigationLink("Test Kit", destination: TestKitView())
                    NavigationLink("Export Reports to PDF", destination: ReportsView())
                    NavigationLink("Notification Kit", destination: NotificationKitView())
                    NavigationLink("Clean Duplicates", destination: UnlockPromptView(feature: "Clean Duplicates"))
                }
            }
            .navigationTitle("Gold Features")
            .listStyle(InsetGroupedListStyle())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
// UnlockPromptView 

import SwiftUI

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
                Task {
                    await IAPManager.shared.purchaseGold()
                }
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
