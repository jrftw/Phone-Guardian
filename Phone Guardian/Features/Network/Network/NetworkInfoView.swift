import SwiftUI
import Network
import SystemConfiguration.CaptiveNetwork
import os

struct NetworkInfoView: View {
    @EnvironmentObject var iapManager: IAPManager
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
    @State private var isSpeedTestLocked = true
    @State private var isAlertPresented = false
    @State private var monitor: NWPathMonitor?
    @State private var timer: Timer?
    private let logger = Logger(subsystem: "com.phoneguardian.network", category: "NetworkInfoView")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription || iapManager.hasRemoveAds) {
                    AdBannerView()
                        .frame(height: 50)
                        .padding(.vertical)
                }
                Text("NETWORK")
                    .font(.title2)
                    .bold()

                HStack(alignment: .top) {
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

                Button(action: performSpeedTest) {
                    Text("Perform Network Speed Test")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

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
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("NetworkInfoView appeared.")
            startMonitoring()
            fetchNetworkDetails()
        }
        .onDisappear {
            monitor?.cancel()
            timer?.invalidate()
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Purchase Required"),
                  message: Text("Purchase tools to unlock this feature, if you already have please navigate to the tools section."),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                activeConnections.removeAll()
                if path.usesInterfaceType(.wifi) {
                    activeConnections.append("Wi-Fi")
                }
                if path.usesInterfaceType(.cellular) {
                    activeConnections.append("Mobile")
                }
                if path.usesInterfaceType(.other) {
                    activeConnections.append("Other")
                }
                logger.info("Active connections updated: \(activeConnections.joined(separator: ", "))")
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.start(queue: queue)

        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            updateNetworkSpeeds()
            updateDataUsage()
        }
    }

    private func updateNetworkSpeeds() {
        let newUpload = Double.random(in: 50...150)
        let newDownload = Double.random(in: 100...300)

        DispatchQueue.main.async {
            uploadSpeed = newUpload
            downloadSpeed = newDownload
            uploadHistory.append(newUpload)
            downloadHistory.append(newDownload)
            if uploadHistory.count > 10 { uploadHistory.removeFirst() }
            if downloadHistory.count > 10 { downloadHistory.removeFirst() }

            logger.debug("Updated speeds - Upload: \(newUpload) KB/s, Download: \(newDownload) KB/s")
        }
    }

    private func updateDataUsage() {
        DispatchQueue.main.async {
            wifiDataSent = DataSent.getWiFiDataSent()
            wifiDataReceived = DataReceived.getWiFiDataReceived()
            mobileDataSent = DataSent.getMobileDataSent()
            mobileDataReceived = DataReceived.getMobileDataReceived()

            logger.debug("Data usage updated - Wi-Fi Sent: \(wifiDataSent), Wi-Fi Received: \(wifiDataReceived), Mobile Sent: \(mobileDataSent), Mobile Received: \(mobileDataReceived)")
        }
    }

    private func fetchNetworkDetails() {
        DispatchQueue.main.async {
            ipDetails = getWiFiDetails() ?? [:]
            logger.info("Fetched Wi-Fi details: \(ipDetails)")
        }
    }

    private func getWiFiDetails() -> [String: String]? {
        var details: [String: String] = [:]
        if let interface = CNCopySupportedInterfaces() as? [String],
           let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface.first! as CFString) as NSDictionary? {
            details["SSID"] = unsafeInterfaceData[kCNNetworkInfoKeySSID as String] as? String ?? "N/A"
            details["BSSID"] = unsafeInterfaceData[kCNNetworkInfoKeyBSSID as String] as? String ?? "N/A"
            details["External IP"] = getExternalIPAddress() ?? "N/A"

            if let ip = getLocalIPAddress() {
                details["IP (V4)"] = ip
            }
        }
        return details
    }

    private func getExternalIPAddress() -> String? {
        return "203.0.113.1"
    }

    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr else { return nil }
                let addrFamily = interface.pointee.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET),
                   let name = String(cString: interface.pointee.ifa_name, encoding: .utf8),
                   name == "en0" {
                    var addr = interface.pointee.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.pointee.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }

    private func performSpeedTest() {
        if isSpeedTestLocked {
            isAlertPresented = true
        } else {
            logger.info("Performing network speed test.")
        }
    }
}
