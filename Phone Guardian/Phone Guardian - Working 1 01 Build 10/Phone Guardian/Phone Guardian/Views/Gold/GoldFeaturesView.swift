import SwiftUI

struct GoldFeaturesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Gold Features!")
                .font(.title)
                .bold()
                .padding()

            List {
                Text("Ad-Free Experience")
                Text("Test Kit")
                Text("Export Reports to PDF")
                Text("Notification Kit")
                Text("Virus Scanner")
                Text("Clean Duplicates")
                Text("Run RAM Deep Clean")
                Text("Priority Support")
            }
        }
        .navigationTitle("Gold Features")
        .padding()
    }
}
