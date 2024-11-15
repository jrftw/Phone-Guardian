import SwiftUI

struct RAMInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("RAM")
                .font(.title2)
                .bold()

            InfoRow(label: "Total RAM", value: getTotalRAM())
            InfoRow(label: "Used RAM", value: "6 GB")
            InfoRow(label: "Free RAM", value: "2 GB")
        }
        .padding()
    }

    func getTotalRAM() -> String {
        let totalRAM = ProcessInfo.processInfo.physicalMemory / 1_073_741_824 // GB
        return "\(totalRAM) GB"
    }
}
