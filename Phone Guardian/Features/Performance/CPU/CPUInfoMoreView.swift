import SwiftUI
import os

struct CPUInfoMoreView: View {
    @EnvironmentObject var iapManager: IAPManager
    private let logger = Logger(subsystem: "com.phoneguardian.cpu", category: "CPUInfoMoreView")
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription || iapManager.hasRemoveAds) {
                    AdBannerView()
                        .frame(height: 50)
                        .padding(.vertical)
                }
                InfoRow(label: "Processor", value: getProcessorInfo())
                InfoRow(label: "Is 64-Bit Process", value: is64BitProcess() ? "Yes" : "No")
                InfoRow(label: "Architecture", value: getArchitecture())
                InfoRow(label: "Active Cores", value: "\(getActiveCores())")
                InfoRow(label: "Efficiency Cores", value: "\(getEfficiencyCores())")
                InfoRow(label: "Performance Cores", value: "\(getPerformanceCores())")
                InfoRow(label: "Total Cores", value: "\(getTotalCores())")
                InfoRow(label: "L1 Data Cache", value: getCacheInfo(level: "L1 Data"))
                InfoRow(label: "L1 Instruction Cache", value: getCacheInfo(level: "L1 Instruction"))
                InfoRow(label: "L2 Cache", value: getCacheInfo(level: "L2"))
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("CPUInfoMoreView appeared.")
        }
    }

    // MARK: - System Information Functions
    func getProcessorInfo() -> String { "Apple Silicon" }
    func is64BitProcess() -> Bool { MemoryLayout<Int>.size == 8 }
    func getArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "ARM64"
        #else
        return "Unknown"
        #endif
    }
    func getActiveCores() -> Int { ProcessInfo.processInfo.activeProcessorCount }
    func getTotalCores() -> Int { ProcessInfo.processInfo.processorCount }
    func getEfficiencyCores() -> Int {
        // Determine efficiency cores based on device model
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        
        // iPhone models with different core configurations
        if modelCode.contains("iPhone14") || modelCode.contains("iPhone15") || modelCode.contains("iPhone16") {
            return 4 // iPhone 14/15/16 have 4 efficiency cores
        } else if modelCode.contains("iPhone13") || modelCode.contains("iPhone12") {
            return 4 // iPhone 12/13 have 4 efficiency cores
        } else if modelCode.contains("iPhone11") {
            return 4 // iPhone 11 has 4 efficiency cores
        } else if modelCode.contains("iPhone8") || modelCode.contains("iPhone9") || modelCode.contains("iPhone10") {
            return 4 // iPhone 8/X/XR/XS have 4 efficiency cores
        } else {
            // Default to 2 for older devices or unknown models
            return 2
        }
    }
    func getPerformanceCores() -> Int { getTotalCores() - getEfficiencyCores() }
    func getCacheInfo(level: String) -> String {
        switch level {
        case "L1 Data": return "192 KB"
        case "L1 Instruction": return "128 KB"
        case "L2": return "12 MB"
        default: return "Unknown"
        }
    }
}
