import SwiftUI
import Network
import SystemConfiguration.CaptiveNetwork
import os

struct NetworkInfoView: View {
    @State private var uploadSpeed: Double = 0
    @State private var downloadSpeed: Double = 0
    @State private var wifiDataSent: UInt64 = 0
    @State private var wifiDataReceived: UInt64 = 0
    @State private var mobileDataSent: UInt64 = 0
    @State private var mobileDataReceived: UInt64 = 0
    @State private var activeConnections: [String] = []
    @State private var ipDetails: [String: String] = [:]
    @State private var uploadHistory: [Double] = []
    @State private var downloadHistory: [Double] = []
    @State private var isMoreInfoPresented = false
    
    private let logger = Logger(subsystem: "com.phoneguardian.network", category: "NetworkInfoView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("NETWORK")
                .font(.title2)
                .bold()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Upload Speed", value: String(format: "%.2f KB/s", uploadSpeed))
                    InfoRow(label: "Download Speed", value: String(format: "%.2f KB/s", downloadSpeed))
                    InfoRow(label: "Wi-Fi Data Sent", value: "\(wifiDataSent / 1_024) KB")
                    InfoRow(label: "Wi-Fi Data Received", value: "\(wifiDataReceived / 1_024) KB")
                    InfoRow(label: "Mobile Data Sent", value: "\(mobileDataSent / 1_024) KB")
                    InfoRow(label: "Mobile Data Received", value: "\(mobileDataReceived / 1_024) KB")

                    Text("Active Connections")
                        .font(.headline)
                    ForEach(activeConnections, id: \.self) { connection in
                        Text("- \(connection)")
                            .foregroundColor(.gray)
                    }

                    Text("Wi-Fi IP Details")
                        .font(.headline)
                    ForEach(ipDetails.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        InfoRow(label: key, value: value)
                    }
                }

                Spacer()

                NetworkUsageChart(uploadHistory: uploadHistory, downloadHistory: downloadHistory)
                    .frame(width: 120, height: 120)
            }

            Spacer()

            Button(action: { isMoreInfoPresented.toggle() }) {
                Text("More Info")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isMoreInfoPresented) {
                NetworkMoreInfoView(activeConnections: activeConnections, ipDetails: ipDetails)
            }
        }
        .padding()
        .onAppear {
            logger.info("NetworkInfoView appeared.")
            startMonitoring()
            fetchNetworkDetails()
        }
    }

    func startMonitoring() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                activeConnections.removeAll()
                if path.usesInterfaceType(.wifi) {
                    activeConnections.append("Wi-Fi")
                }
                if path.usesInterfaceType(.cellular) {
                    activeConnections.append("Mobile")
                }
                if path.usesInterfaceType(.other) {
                    activeConnections.append("VPN or Hotspot")
                }
                logger.info("Active connections updated: \(activeConnections.joined(separator: ", "))")
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            updateNetworkSpeeds()
        }
    }

    func updateNetworkSpeeds() {
        let newUpload = Double.random(in: 50...150)
        let newDownload = Double.random(in: 100...300)

        DispatchQueue.main.async {
            uploadSpeed = newUpload
            downloadSpeed = newDownload
            uploadHistory.append(newUpload)
            downloadHistory.append(newDownload)
            if uploadHistory.count > 10 { uploadHistory.removeFirst() }
            if downloadHistory.count > 10 { downloadHistory.removeFirst() }
            
            logger.debug("Updated speeds - Upload: \(newUpload, privacy: .public) KB/s, Download: \(newDownload, privacy: .public) KB/s")
        }
    }

    func fetchNetworkDetails() {
        DispatchQueue.main.async {
            ipDetails = getWiFiDetails() ?? [:]
            logger.info("Fetched Wi-Fi details: \(ipDetails, privacy: .public)")
        }
    }

    func getWiFiDetails() -> [String: String]? {
        var details: [String: String] = [:]
        if let interface = CNCopySupportedInterfaces() as? [String],
           let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface.first! as CFString) as? [String: AnyObject] {
            details["SSID"] = unsafeInterfaceData[kCNNetworkInfoKeySSID as String] as? String ?? "N/A"
            details["BSSID"] = unsafeInterfaceData[kCNNetworkInfoKeyBSSID as String] as? String ?? "N/A"
            details["External IP"] = getExternalIPAddress() ?? "N/A"

            if let ip = getLocalIPAddress() {
                details["IP (V4)"] = ip
            }
        }
        return details
    }

    func getExternalIPAddress() -> String? {
        return "203.0.113.1"
    }

    func getLocalIPAddress() -> String? {
        return "192.168.1.100"
    }
}

struct NetworkUsageChart: View {
    let uploadHistory: [Double]
    let downloadHistory: [Double]

    var body: some View {
        GeometryReader { geometry in
            let maxData = max((uploadHistory + downloadHistory).max() ?? 1, 1)
            Path { path in
                guard uploadHistory.count > 1 else { return }
                let stepX = geometry.size.width / CGFloat(uploadHistory.count - 1)
                path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(uploadHistory[0] / maxData) * geometry.size.height))
                for index in 1..<uploadHistory.count {
                    path.addLine(to: CGPoint(x: CGFloat(index) * stepX, y: geometry.size.height - CGFloat(uploadHistory[index] / maxData) * geometry.size.height))
                }
            }
            .stroke(Color.green, lineWidth: 2)
        }
    }
}
