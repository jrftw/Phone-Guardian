// StorageInfoView.swift

import SwiftUI
import os

struct StorageInfoView: View {
    @State private var showClearCacheView = false
    @AppStorage("enableLogging") private var enableLogging = false
    @EnvironmentObject var iapManager: IAPManager
    private let logger = Logger(subsystem: "com.phoneguardian.storage", category: "StorageInfoView")
    @ObservedObject var duplicateScanner = DuplicateScanner.shared
    @State private var duplicateScanError: String?
    @State private var isAdLoading = false
    @State private var showScanView = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STORAGE")
                .font(.title2)
                .bold()

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
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fullScreenCover(isPresented: $showClearCacheView) {
                ClearCacheView()
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
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(iapManager.hasGoldSubscription ? Color.green : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isAdLoading)

            Spacer()
        }
        .padding()
        .onAppear {
            logEvent("StorageInfoView appeared.")
        }
        .fullScreenCover(isPresented: $showScanView) {
            DuplicateScanView()
        }
    }

    private var canShowAd: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        if UIDevice.current.userInterfaceIdiom == .pad { return false }
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" { return false }
        return InterstitialAdHandler.shared.isAdReady
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
            logger.info("\(message)")
        }
    }

    private func startDuplicateScan() {
        showScanView = true
        duplicateScanner.startDuplicateScan()
    }

    private func showAdForAccess() {
        isAdLoading = true
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
    }

    private func purchaseGold() {
        Task {
            await iapManager.purchaseGold()
        }
    }
}
