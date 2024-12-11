import SwiftUI

struct DetailedCPUView: View {
    let userUsage: Double
    let systemUsage: Double
    let idleUsage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CPU Detailed Usage")
                .font(.title2)
                .bold()

            CPUPieChartView(user: userUsage, system: systemUsage, idle: idleUsage)
                .frame(height: 250)

            CPUInfoMoreView()

            Text("Definitions")
                .font(.headline)
                .padding(.top, 16)
            DefinitionsView()

            Spacer()
        }
        .padding()
    }
}
