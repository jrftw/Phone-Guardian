import SwiftUI

struct TestResultsView: View {
    let savedResults: [NetworkTestResult]

    var body: some View {
        TabView {
            TestHistoryView(testHistory: savedResults)
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            DowndetectorView()
                .tabItem {
                    Label("Downdetector", systemImage: "antenna.radiowaves.left.and.right")
                }
        }
    }
}
