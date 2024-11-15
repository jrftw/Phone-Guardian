import SwiftUI

struct StorageInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STORAGE")
                .font(.title2)
                .bold()

            InfoRow(label: "Total Storage", value: getTotalDiskSpace())
            InfoRow(label: "Used Storage", value: getUsedDiskSpace())
            InfoRow(label: "Free Storage", value: getFreeDiskSpace())
        }
        .padding()
    }

    func getTotalDiskSpace() -> String {
        if let totalSpace = try? URL(fileURLWithPath: NSHomeDirectory() as String)
            .resourceValues(forKeys: [.volumeTotalCapacityKey]).volumeTotalCapacity {
            return "\(totalSpace / 1_073_741_824) GB"
        }
        return "N/A"
    }

    func getUsedDiskSpace() -> String {
        let total = getTotalDiskSpace()
        let free = getFreeDiskSpace()
        guard let totalValue = Int(total.replacingOccurrences(of: " GB", with: "")),
              let freeValue = Int(free.replacingOccurrences(of: " GB", with: "")) else { return "N/A" }
        return "\(totalValue - freeValue) GB"
    }

    func getFreeDiskSpace() -> String {
        if let freeSpace = try? URL(fileURLWithPath: NSHomeDirectory() as String)
            .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            return "\(freeSpace / 1_073_741_824) GB"
        }
        return "N/A"
    }
}
