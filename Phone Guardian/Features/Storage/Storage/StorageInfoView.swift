import SwiftUI
import UIKit

struct StorageInfoView: View {
    @State private var showClearCacheView = false
    @AppStorage("enableLogging") private var enableLogging = false
    @EnvironmentObject var iapManager: IAPManager
    @ObservedObject var duplicateScanner = DuplicateScanner.shared
    @State private var duplicateScanError: String?
    @State private var isAdLoading = false
    @State private var showScanView = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Storage Overview Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Storage Overview", icon: "externaldrive")
                    
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            ModernInfoRow(icon: "externaldrive.fill", label: "Total Storage", value: getTotalDiskSpace(), iconColor: .blue)
                            ModernInfoRow(icon: "externaldrive.badge.checkmark", label: "Used Storage", value: getUsedDiskSpace(), iconColor: .orange)
                            ModernInfoRow(icon: "externaldrive.badge.plus", label: "Free Storage", value: getFreeDiskSpace(), iconColor: .green)
                            ModernInfoRow(icon: "arrow.up.circle", label: "Releasable Space", value: getReleasableSpace(), iconColor: .purple)
                        }
                        
                        Spacer()
                        
                        StorageBarChart(usedPercentage: getUsedPercentage())
                            .frame(width: 120, height: 120)
                            .modernCard(padding: 12)
                    }
                }
                .modernCard()
                
                // Action Buttons Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Storage Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            showClearCacheView = true
                            logEvent("Clear Cache button tapped.")
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Cache & Temp Files")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
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
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text(duplicateButtonTitle)
                            }
                        }
                        .modernButton(backgroundColor: iapManager.hasGoldSubscription ? .green : .orange)
                        .disabled(isAdLoading)
                    }
                }
                .modernCard()
                
                // App Size Analyzer Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "App Size Analyzer", icon: "apps.iphone")
                    NavigationLink(destination: AppSizeAnalyzerView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "apps.iphone")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analyze Installed Apps")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("See which apps use the most space")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .modernCard()
                
                // Media Library Analyzer Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Media Library Analyzer", icon: "photo.on.rectangle")
                    NavigationLink(destination: MediaLibraryAnalyzerView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Analyze Media Library")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Find large photos, videos, and more")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.quaternary, lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logEvent("StorageInfoView appeared.")
            InterstitialAdHandler.shared.preloadAd()
        }
        .sheet(isPresented: $showScanView) {
            DuplicateScanView()
                .interactiveDismissDisabled(false)
        }
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
