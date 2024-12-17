import SwiftUI

struct StorageInfoView: View {
    @State private var showClearCacheView = false
    @AppStorage("enableLogging") private var enableLogging = false
    @EnvironmentObject var iapManager: IAPManager
    @ObservedObject var duplicateScanner = DuplicateScanner.shared
    @State private var duplicateScanError: String?
    @State private var isAdLoading = false
    @State private var showScanView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STORAGE")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading) {
                    StorageInfoRow(label: "Total Storage", value: getTotalDiskSpace())
                    StorageInfoRow(label: "Used Storage", value: getUsedDiskSpace())
                    StorageInfoRow(label: "Free Storage", value: getFreeDiskSpace())
                    StorageInfoRow(label: "Releasable Space", value: getReleasableSpace())
                }
                Spacer()
                StorageBarChart(usedPercentage: getUsedPercentage())
                    .frame(width: 100, height: 20)
            }

            Button(action: {
                showClearCacheView = true
                logEvent("Clear Cache button tapped.")
            }) {
                Text("Clear Cache & Temp Files")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showClearCacheView) {
                ClearCacheView()
                    .interactiveDismissDisabled(false)
            }

            Button(action: {
                if iapManager.hasGoldSubscription {
                    startDuplicateScan()
                } else {
                    if canShowAd {
                        showAdForAccess()
                    } else {
                        purchaseGold()
                    }
                }
            }) {
                Text(duplicateButtonTitle)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(iapManager.hasGoldSubscription ? Color.green : Color.orange)
                    .cornerRadius(10)
            }
            .disabled(isAdLoading)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            logEvent("StorageInfoView appeared.")
            InterstitialAdHandler.shared.preloadAd()
        }
        .sheet(isPresented: $showScanView) {
            DuplicateScanView()
                .interactiveDismissDisabled(false)
        }
        .colorScheme(.dark)
    }

    private var canShowAd: Bool {
        #if os(iOS)
        if PGEnvironment.isSimulator { return false }
        if PGEnvironment.isTestFlight { return false }
        return InterstitialAdHandler.shared.isAdReady
        #else
        return false
        #endif
    }

    private var duplicateButtonTitle: String {
        if iapManager.hasGoldSubscription {
            return "Check for Duplicates"
        } else if canShowAd {
            return "Watch Ad to Unlock"
        } else {
            return "Purchase Gold to Check For Duplicates"
        }
    }

    private func getTotalDiskSpace() -> String {
        if let totalSpace = try? URL(fileURLWithPath: NSHomeDirectory())
            .resourceValues(forKeys: [.volumeTotalCapacityKey]).volumeTotalCapacity {
            return "\(totalSpace / 1_073_741_824) GB"
        }
        return "N/A"
    }

    private func getUsedDiskSpace() -> String {
        let total = getTotalDiskSpace()
        let free = getFreeDiskSpace()
        guard let totalValue = Int(total.replacingOccurrences(of: " GB", with: "")),
              let freeValue = Int(free.replacingOccurrences(of: " GB", with: "")) else { return "N/A" }
        return "\(totalValue - freeValue) GB"
    }

    private func getFreeDiskSpace() -> String {
        if let freeSpace = try? URL(fileURLWithPath: NSHomeDirectory())
            .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            return "\(freeSpace / 1_073_741_824) GB"
        }
        return "N/A"
    }

    private func getReleasableSpace() -> String {
        return "2 GB"
    }

    private func getUsedPercentage() -> Double {
        let total = Double(getTotalDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 1
        let used = Double(getUsedDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 0
        return (used / total) * 100
    }

    private func logEvent(_ message: String) {
        if enableLogging {
            print(message)
        }
    }

    private func startDuplicateScan() {
        showScanView = true
        duplicateScanner.startDuplicateScan()
    }

    private func showAdForAccess() {
        isAdLoading = true
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {
            InterstitialAdHandler.shared.show(from: rootViewController) { success in
                DispatchQueue.main.async {
                    self.isAdLoading = false
                    if success {
                        self.startDuplicateScan()
                    } else {
                        self.duplicateScanError = "Failed to show ad."
                    }
                }
            }
        } else {
            isAdLoading = false
            self.duplicateScanError = "Unable to display ad at this time."
        }
        #else
        isAdLoading = false
        self.duplicateScanError = "Ads not available on this platform."
        #endif
    }

    private func purchaseGold() {
        Task {
            await iapManager.purchaseGold()
        }
    }
}
