import SwiftUI

struct SystemServicesInfoView: View {
    @StateObject private var servicesManager = SystemServicesManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ModernSectionHeader(title: "System Services", icon: "gearshape")
                LazyVStack(spacing: 12) {
                    ModernInfoRow(icon: "gearshape", label: "Total Services", value: "\(servicesManager.serviceStatistics.totalServices)", iconColor: .blue)
                    ModernInfoRow(icon: "gearshape.2", label: "Active Services", value: "\(servicesManager.serviceStatistics.activeServices)", iconColor: .green)
                    ModernInfoRow(icon: "bolt", label: "Total Battery Impact", value: String(format: "%.1f", servicesManager.serviceStatistics.totalBatteryImpact), iconColor: .orange)
                    ModernInfoRow(icon: "arrow.up.arrow.down", label: "Total Data Usage", value: "\(ByteCountFormatter.string(fromByteCount: Int64(servicesManager.serviceStatistics.totalDataUsage), countStyle: .binary))", iconColor: .purple)
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("System Services")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await servicesManager.startMonitoring() }
        }
        .onDisappear {
            servicesManager.stopMonitoring()
        }
    }
} 