import SwiftUI
import os

struct DetailedCPUView: View {
    let userUsage: Double
    let systemUsage: Double
    let idleUsage: Double

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("CPU Detailed View")
                    .font(.title2)
                    .bold()

                CPUPieChartView(user: userUsage, system: systemUsage, idle: idleUsage)
                    .frame(height: 200)

                Divider()

                Text("More Info")
                    .font(.headline)

                CPUInfoMoreView()

                Divider()

                Text("Definitions")
                    .font(.headline)

                DefinitionsView()
            }
            .padding()
        }
    }
}
