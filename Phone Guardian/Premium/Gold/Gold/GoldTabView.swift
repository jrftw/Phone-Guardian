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
