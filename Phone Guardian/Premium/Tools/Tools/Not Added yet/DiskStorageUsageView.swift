// DiskStorageUsageView.swift

import SwiftUI

struct DiskStorageUsageView: View {
    var body: some View {
        VStack {
            Text("Disk Storage Usage")
                .font(.largeTitle)
                .padding()
            
            List {
                StorageInfoRow(label: "Total Storage", value: getTotalDiskSpace())
                StorageInfoRow(label: "Used Storage", value: getUsedDiskSpace())
                StorageInfoRow(label: "Free Storage", value: getFreeDiskSpace())
                StorageInfoRow(label: "Releasable Space", value: getReleasableSpace())
            }
            
            StorageBarChart(usedPercentage: getUsedPercentage())
                .frame(height: 20)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Disk Storage Usage")
    }
    
    func getTotalDiskSpace() -> String {
        if let totalSpace = try? URL(fileURLWithPath: NSHomeDirectory())
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
        if let freeSpace = try? URL(fileURLWithPath: NSHomeDirectory())
            .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            return "\(freeSpace / 1_073_741_824) GB"
        }
        return "N/A"
    }
    
    func getReleasableSpace() -> String {
        return "2 GB"
    }
    
    func getUsedPercentage() -> Double {
        let total = Double(getTotalDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 1
        let used = Double(getUsedDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 0
        return (used / total) * 100
    }
}

struct ToolsStorageBarChart: View {
    let usedPercentage: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: geometry.size.height)

                Rectangle()
                    .fill(usedPercentage > 80 ? Color.red : usedPercentage > 50 ? Color.orange : Color.green)
                    .frame(width: geometry.size.width * CGFloat(usedPercentage / 100), height: geometry.size.height)
            }
            .cornerRadius(5)
        }
    }
}

struct ToolsDiskStorageInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}
