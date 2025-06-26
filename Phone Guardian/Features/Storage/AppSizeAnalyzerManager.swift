// MARK: LOG: STORAGE
import Foundation
import UIKit
import SwiftUI
import os

class AppSizeAnalyzerManager: ObservableObject {
    static let shared = AppSizeAnalyzerManager()
    private let logger = Logger(subsystem: "com.phoneguardian.appsizeanalyzer", category: "AppSizeAnalyzerManager")

    @Published var installedApps: [AppInfo] = []
    @Published var appCategories: [AppCategory] = []
    @Published var totalAppSize: UInt64 = 0
    @Published var analysisStatus: AnalysisStatus = .idle
    @Published var lastAnalysisDate: Date?

    enum AnalysisStatus {
        case idle, analyzing, completed, error
    }

    struct AppInfo: Identifiable {
        let id = UUID()
        let bundleIdentifier: String
        let displayName: String
        let version: String
        let appBinarySize: UInt64
        let documentsDataSize: UInt64
        let cacheSize: UInt64
        let totalSize: UInt64
        let installDate: Date?
        let lastUsedDate: Date?
        let category: AppCategory
        let isSystemApp: Bool

        var formattedTotalSize: String {
            return AppSizeAnalyzerManager.formatBytes(totalSize)
        }

        var formattedAppBinarySize: String {
            return AppSizeAnalyzerManager.formatBytes(appBinarySize)
        }

        var formattedDocumentsDataSize: String {
            return AppSizeAnalyzerManager.formatBytes(documentsDataSize)
        }

        var formattedCacheSize: String {
            return AppSizeAnalyzerManager.formatBytes(cacheSize)
        }
    }

    struct AppCategory: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
        let totalSize: UInt64
        let appCount: Int
        let apps: [AppInfo]

        var formattedTotalSize: String {
            return AppSizeAnalyzerManager.formatBytes(totalSize)
        }
    }

    func analyzeInstalledApps() async {
        logger.info("Starting app size analysis")
        
        await MainActor.run {
            self.analysisStatus = .analyzing
        }

        await Task.detached(priority: .userInitiated) {
            await self.scanInstalledApps()
            await self.categorizeApps()
            await self.calculateTotals()
        }.value

        await MainActor.run {
            self.lastAnalysisDate = Date()
            self.analysisStatus = .completed
        }
        logger.info("App size analysis completed. Found \(self.installedApps.count) apps")
    }

    private func scanInstalledApps() async {
        logger.debug("Scanning installed apps")
        let simulatedApps = await simulateInstalledApps()
        await MainActor.run {
            self.installedApps = simulatedApps
        }
    }

    private func categorizeApps() async {
        logger.debug("Categorizing apps")

        let categories = [
            ("Social Media", "message", Color.blue),
            ("Games", "gamecontroller", Color.purple),
            ("Productivity", "briefcase", Color.green),
            ("Entertainment", "tv", Color.orange),
            ("Utilities", "wrench.and.screwdriver", Color.gray),
            ("System", "gear", Color.red),
            ("Other", "ellipsis.circle", Color.secondary)
        ]

        var categorizedApps: [AppCategory] = []

        for (categoryName, icon, color) in categories {
            let categoryApps = installedApps.filter { $0.category.name == categoryName }
            let totalSize = categoryApps.reduce(0) { $0 + $1.totalSize }

            let category = AppCategory(
                name: categoryName,
                icon: icon,
                color: color,
                totalSize: totalSize,
                appCount: categoryApps.count,
                apps: categoryApps
            )

            categorizedApps.append(category)
        }

        await MainActor.run {
            self.appCategories = categorizedApps.sorted { $0.totalSize > $1.totalSize }
        }
    }

    private func calculateTotals() async {
        logger.debug("Calculating total app sizes")

        let totalSize = installedApps.reduce(0) { $0 + $1.totalSize }

        await MainActor.run {
            self.totalAppSize = totalSize
        }
    }

    private func simulateInstalledApps() async -> [AppInfo] {
        let appTemplates = [
            ("com.facebook.Facebook", "Facebook", "Social Media", true),
            ("com.instagram.Instagram", "Instagram", "Social Media", true),
            ("com.twitter.Twitter", "Twitter", "Social Media", true),
            ("com.snapchat.Snapchat", "Snapchat", "Social Media", true),
            ("com.tencent.wechat", "WeChat", "Social Media", true),
            ("com.activision.callofduty", "Call of Duty", "Games", false),
            ("com.epicgames.fortnite", "Fortnite", "Games", false),
            ("com.mojang.minecraft", "Minecraft", "Games", false),
            ("com.spotify.client", "Spotify", "Entertainment", false),
            ("com.netflix.Netflix", "Netflix", "Entertainment", false),
            ("com.apple.Music", "Apple Music", "Entertainment", true),
            ("com.apple.Photos", "Photos", "System", true),
            ("com.apple.Camera", "Camera", "System", true),
            ("com.apple.Messages", "Messages", "System", true),
            ("com.apple.Mail", "Mail", "System", true),
            ("com.apple.Safari", "Safari", "System", true),
            ("com.microsoft.Office.Word", "Microsoft Word", "Productivity", false),
            ("com.microsoft.Office.Excel", "Microsoft Excel", "Productivity", false),
            ("com.adobe.Photoshop", "Adobe Photoshop", "Productivity", false),
            ("com.google.Chrome", "Google Chrome", "Utilities", false),
            ("com.apple.Weather", "Weather", "Utilities", true),
            ("com.apple.Calculator", "Calculator", "Utilities", true),
            ("com.apple.Notes", "Notes", "Utilities", true)
        ]

        var apps: [AppInfo] = []

        for (bundleId, name, category, isSystem) in appTemplates {
            let appBinarySize = UInt64.random(in: 50_000_000...500_000_000)
            let documentsDataSize = UInt64.random(in: 10_000_000...200_000_000)
            let cacheSize = UInt64.random(in: 5_000_000...100_000_000)
            let totalSize = appBinarySize + documentsDataSize + cacheSize

            let installDate = Date().addingTimeInterval(-TimeInterval.random(in: 0...365*24*3600))
            let lastUsedDate = Date().addingTimeInterval(-TimeInterval.random(in: 0...7*24*3600))

            let app = AppInfo(
                bundleIdentifier: bundleId,
                displayName: name,
                version: "\(Int.random(in: 1...20)).\(Int.random(in: 0...9)).\(Int.random(in: 0...9))",
                appBinarySize: appBinarySize,
                documentsDataSize: documentsDataSize,
                cacheSize: cacheSize,
                totalSize: totalSize,
                installDate: installDate,
                lastUsedDate: lastUsedDate,
                category: AppCategory(name: category, icon: "", color: .blue, totalSize: 0, appCount: 0, apps: []),
                isSystemApp: isSystem
            )

            apps.append(app)
        }

        return apps.sorted { $0.totalSize > $1.totalSize }
    }

    func getLargestApps(limit: Int = 10) -> [AppInfo] {
        return Array(installedApps.prefix(limit))
    }

    func getAppsByCategory(_ categoryName: String) -> [AppInfo] {
        return installedApps.filter { $0.category.name == categoryName }
    }

    func getSystemApps() -> [AppInfo] {
        return installedApps.filter { $0.isSystemApp }
    }

    func getUserApps() -> [AppInfo] {
        return installedApps.filter { !$0.isSystemApp }
    }

    func getAppsWithLargeCache(threshold: UInt64 = 50_000_000) -> [AppInfo] {
        return installedApps.filter { $0.cacheSize > threshold }
    }

    func getAppsWithLargeDocuments(threshold: UInt64 = 100_000_000) -> [AppInfo] {
        return installedApps.filter { $0.documentsDataSize > threshold }
    }

    func getUnusedApps(daysThreshold: Int = 30) -> [AppInfo] {
        let thresholdDate = Calendar.current.date(byAdding: .day, value: -daysThreshold, to: Date()) ?? Date()
        return installedApps.filter { app in
            guard let lastUsed = app.lastUsedDate else { return false }
            return lastUsed < thresholdDate
        }
    }

    func getAnalysisStatusDescription() -> String {
        switch analysisStatus {
        case .idle: return "Ready to analyze"
        case .analyzing: return "Analyzing apps..."
        case .completed: return "Analysis completed"
        case .error: return "Analysis failed"
        }
    }

    func getAnalysisStatusColor() -> Color {
        switch analysisStatus {
        case .idle: return .gray
        case .analyzing: return .orange
        case .completed: return .green
        case .error: return .red
        }
    }

    static func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func getSizeBreakdownPercentage(_ size: UInt64, total: UInt64) -> Double {
        guard total > 0 else { return 0.0 }
        return Double(size) / Double(total) * 100.0
    }

    func getAppSizeDescription(_ size: UInt64) -> String {
        if size < 100_000_000 {
            return "Small"
        } else if size < 500_000_000 {
            return "Medium"
        } else if size < 1_000_000_000 {
            return "Large"
        } else {
            return "Very Large"
        }
    }

    func getAppSizeColor(_ size: UInt64) -> Color {
        if size < 100_000_000 {
            return .green
        } else if size < 500_000_000 {
            return .orange
        } else {
            return .red
        }
    }

    func clearAnalysisData() {
        logger.info("Clearing app analysis data")
        installedApps.removeAll()
        appCategories.removeAll()
        totalAppSize = 0
        analysisStatus = .idle
    }
}
