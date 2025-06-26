import SwiftUI

struct SignalStrengthInfoView: View {
    @StateObject private var signalManager = SignalStrengthManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ModernSectionHeader(title: "Signal Strength", icon: "antenna.radiowaves.left.and.right")
                LazyVStack(spacing: 12) {
                    ModernInfoRow(icon: "antenna.radiowaves.left.and.right", label: "Cellular Carrier", value: signalManager.cellularSignal.carrier, iconColor: .blue)
                    ModernInfoRow(icon: "wifi", label: "WiFi SSID", value: signalManager.wifiSignal.ssid, iconColor: .green)
                    ModernInfoRow(icon: "antenna.radiowaves.left.and.right", label: "Cellular RSSI", value: String(format: "%.0f dBm", signalManager.cellularSignal.rssi), iconColor: .orange)
                    ModernInfoRow(icon: "wifi", label: "WiFi RSSI", value: String(format: "%.0f dBm", signalManager.wifiSignal.rssi), iconColor: .orange)
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Signal Strength")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await signalManager.startMonitoring() }
        }
        .onDisappear {
            signalManager.stopMonitoring()
        }
    }
} 