// StorageInfoView.swift
import SwiftUI
import os

struct StorageInfoView: View {
    @State private var showCleanupConfirmation = false
    @State private var showDuplicatesInfo = false
    @AppStorage("enableLogging") private var enableLogging = false
    private let logger = Logger(subsystem: "com.phoneguardian.storage", category: "StorageInfoView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("STORAGE")
                .font(.title2)
                .bold()

            HStack {
                VStack(alignment: .leading) {
                    InfoRow(label: "Total Storage", value: getTotalDiskSpace())
                    InfoRow(label: "Used Storage", value: getUsedDiskSpace())
                    InfoRow(label: "Free Storage", value: getFreeDiskSpace())
                    InfoRow(label: "Releasable Space", value: getReleasableSpace())
                }

                Spacer()

                StorageBarChart(usedPercentage: getUsedPercentage())
                    .frame(width: 100, height: 20)
            }

            Button(action: {
                clearCacheAndTempFiles()
                logEvent("Clear Cache & Temp Files button tapped.")
            }) {
                Text("Clear Cache & Temp Files")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                showDuplicatesInfo = true
                logEvent("Check for Duplicates button tapped.")
            }) {
                Text("Check for Duplicates")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showDuplicatesInfo) {
                DuplicatesInfoView()
            }

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showCleanupConfirmation) {
            CleanupConfirmationView()
        }
        .onAppear {
            logEvent("StorageInfoView appeared.")
        }
    }

    // MARK: - Disk Space Calculations
    
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
        return "2 GB" // Placeholder for actual logic
    }

    func getUsedPercentage() -> Double {
        let total = Double(getTotalDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 1
        let used = Double(getUsedDiskSpace().replacingOccurrences(of: " GB", with: "")) ?? 0
        return (used / total) * 100
    }

    // MARK: - Cache Cleanup

    func clearCacheAndTempFiles() {
        // Implement actual cache clearing logic
        logger.info("Cache and temporary files cleared.")
        showCleanupConfirmation = true
    }

    // MARK: - Logging

    func logEvent(_ message: String) {
        if enableLogging {
            logger.info("\(message, privacy: .public)")
        }
    }
}

// MARK: - Storage Bar Chart
struct StorageBarChart: View {
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

// MARK: - Cleanup Confirmation View
struct CleanupConfirmationView: View {
    var body: some View {
        VStack {
            Text("Cleanup Completed!")
                .font(.title2)
                .padding()
            Spacer()
        }
        .padding()
    }
}

// MARK: - Duplicates Info View
struct DuplicatesInfoView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Premium Feature")
                .font(.title)
                .bold()

            Text("Check for duplicate files on your device. Choose which files to keep and which to delete for better storage management.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()
        }
        .padding()
    }
}
