import SwiftUI
import Network

struct NetworkInfoView: View {
    @State private var uploadSpeed: Double = 0
    @State private var downloadSpeed: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("NETWORK")
                .font(.title2)
                .bold()
            
            InfoRow(label: "Upload Speed", value: String(format: "%.2f KB/s", uploadSpeed))
            InfoRow(label: "Download Speed", value: String(format: "%.2f KB/s", downloadSpeed))
        }
        .padding()
        .onAppear {
            monitorNetwork()
        }
    }

    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Simulated speeds for now, replace with actual logic
                self.uploadSpeed = Double.random(in: 50...200)
                self.downloadSpeed = Double.random(in: 100...500)
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
