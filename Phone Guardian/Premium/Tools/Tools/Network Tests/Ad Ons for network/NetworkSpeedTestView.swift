import SwiftUI
import os
import SystemConfiguration

struct NetworkSpeedTestView: View {
    @State private var isTesting = false
    @State private var downloadSpeed: String = "-"
    @State private var uploadSpeed: String = "-"
    @State private var ping: String = "-"
    @State private var internalIP: String = "Fetching..."
    @State private var externalIP: String = "Fetching..."
    @State private var savedResults: [NetworkTestResult] = []
    @State private var isResultsViewPresented = false
    private let logger = Logger(subsystem: "com.phoneguardian.network", category: "NetworkSpeedTestView")

    var body: some View {
        VStack(spacing: 16) {
            Text("Network Speed Test")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                NetworkDetailRow(label: "Internal IP", value: internalIP)
                NetworkDetailRow(label: "External IP", value: externalIP)
                NetworkDetailRow(label: "Ping", value: "\(ping) ms")
                NetworkDetailRow(label: "Download Speed", value: "\(downloadSpeed) Mbps")
                NetworkDetailRow(label: "Upload Speed", value: "\(uploadSpeed) Mbps")
            }
            .padding()

            Button(action: startSpeedTest) {
                Text(isTesting ? "Testing..." : "Start Test")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isTesting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isTesting)

            Button(action: { isResultsViewPresented.toggle() }) {
                Text("View Test Results")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fullScreenCover(isPresented: $isResultsViewPresented) {
                NavigationView {
                    TestResultsView(savedResults: savedResults)
                        .navigationTitle("Test Results")
                        .navigationBarItems(trailing: Button("Done") {
                            isResultsViewPresented = false
                        })
                }
            }
        }
        .padding()
        .onAppear {
            fetchNetworkDetails()
            loadSavedResults()
        }
        .navigationTitle("Network Speed Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func startSpeedTest() {
        logger.info("Starting speed test.")
        isTesting = true
        downloadSpeed = "-"
        uploadSpeed = "-"
        ping = "-"

        let group = DispatchGroup()

        group.enter()
        performPingTest { pingResult in
            self.ping = String(format: "%.2f", pingResult)
            self.logger.info("Ping test completed: \(self.ping) ms")
            group.leave()
        }

        group.enter()
        DownloadSpeedTester.testDownloadSpeed { downloadResult in
            self.downloadSpeed = String(format: "%.2f", downloadResult)
            self.logger.info("Download test completed: \(self.downloadSpeed) Mbps")
            group.leave()
        }

        group.enter()
        UploadSpeedTester.testUploadSpeed { uploadResult in
            self.uploadSpeed = String(format: "%.2f", uploadResult)
            self.logger.info("Upload test completed: \(self.uploadSpeed) Mbps")
            group.leave()
        }

        group.notify(queue: .main) {
            self.isTesting = false
            self.saveTestResult()
            self.logger.info("Speed test completed.")
        }
    }

    private func performPingTest(completion: @escaping (Double) -> Void) {
        guard let url = URL(string: "https://www.google.com") else {
            completion(0)
            return
        }
        let startTime = CFAbsoluteTimeGetCurrent()
        let task = URLSession.shared.dataTask(with: url) { _, _, _ in
            let elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
            completion(elapsedTime)
        }
        task.resume()
    }

    private func saveTestResult() {
        let newResult = NetworkTestResult(
            id: UUID().uuidString,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            ping: ping,
            date: Date()
        )
        savedResults.insert(newResult, at: 0)
        if savedResults.count > 5 {
            savedResults = Array(savedResults.prefix(5))
        }
        saveResultsToUserDefaults()
        logger.info("Test result saved.")
    }

    private func saveResultsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(savedResults) {
            UserDefaults.standard.set(encoded, forKey: "NetworkSpeedTestResults")
        }
    }

    private func loadSavedResults() {
        if let savedData = UserDefaults.standard.data(forKey: "NetworkSpeedTestResults"),
           let loadedResults = try? JSONDecoder().decode([NetworkTestResult].self, from: savedData) {
            self.savedResults = loadedResults
            logger.info("Loaded saved test results.")
        }
    }

    private func fetchNetworkDetails() {
        DispatchQueue.global(qos: .background).async {
            let internalIP = self.getLocalIPAddress() ?? "Unavailable"
            let externalIP = self.getExternalIPAddress() ?? "Unavailable"
            DispatchQueue.main.async {
                self.internalIP = internalIP
                self.externalIP = externalIP
                self.logger.info("Fetched network details.")
            }
        }
    }

    private func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                let addrFamily = interface.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
                   let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let result = getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                             &hostname, socklen_t(hostname.count),
                                             nil, socklen_t(0), NI_NUMERICHOST)
                    if result == 0 {
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }

    private func getExternalIPAddress() -> String? {
        return try? String(contentsOf: URL(string: "https://api.ipify.org")!)
    }
}
