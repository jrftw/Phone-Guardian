import SwiftUI

struct CPUInfoMoreView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }

    // MARK: - System Information Functions
    func getProcessorInfo() -> String {
        return "Apple Silicon"
    }

    func is64BitProcess() -> Bool {
        return MemoryLayout<Int>.size == 8
    }

    func getArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "ARM64"
        #else
        return "Unknown"
        #endif
    }

    func getActiveCores() -> Int {
        return ProcessInfo.processInfo.activeProcessorCount
    }

    func getTotalCores() -> Int {
        return ProcessInfo.processInfo.processorCount
    }

    func getEfficiencyCores() -> Int {
        return 2 // Placeholder
    }

    func getPerformanceCores() -> Int {
        return getTotalCores() - getEfficiencyCores()
    }

    func getCacheInfo(level: String) -> String {
        switch level {
        case "L1 Data":
            return "192 KB"
        case "L1 Instruction":
            return "128 KB"
        case "L2":
            return "12 MB"
        default:
            return "Unknown"
        }
    }
}
