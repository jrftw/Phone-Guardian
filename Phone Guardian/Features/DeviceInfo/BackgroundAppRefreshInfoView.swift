import SwiftUI

struct BackgroundAppRefreshInfoView: View {
    @StateObject private var refreshManager = BackgroundAppRefreshManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ModernSectionHeader(title: "Background App Refresh", icon: "arrow.clockwise")
                LazyVStack(spacing: 12) {
                    ModernInfoRow(icon: "apps.iphone", label: "Total Apps", value: "\(refreshManager.refreshStatistics.totalApps)", iconColor: .blue)
                    ModernInfoRow(icon: "apps.iphone.badge.plus", label: "Enabled Apps", value: "\(refreshManager.refreshStatistics.enabledApps)", iconColor: .green)
                    ModernInfoRow(icon: "bolt", label: "Total Battery Impact", value: String(format: "%.1f", refreshManager.refreshStatistics.totalBatteryImpact), iconColor: .orange)
                    ModernInfoRow(icon: "arrow.up.arrow.down", label: "Total Data Consumed", value: "\(ByteCountFormatter.string(fromByteCount: Int64(refreshManager.refreshStatistics.totalDataConsumed), countStyle: .binary))", iconColor: .purple)
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Background App Refresh")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await refreshManager.startMonitoring() }
        }
        .onDisappear {
            refreshManager.stopMonitoring()
        }
    }
} 