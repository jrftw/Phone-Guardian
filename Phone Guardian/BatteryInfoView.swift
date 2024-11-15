import SwiftUI
import os

struct BatteryInfoView: View {
    private let logger = Logger(subsystem: "com.phoneguardian.battery", category: "BatteryInfoView")
    
    init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("BATTERY")
                .font(.title2)
                .bold()

            InfoRow(label: "Battery Level", value: "\(Int(UIDevice.current.batteryLevel * 100))%")
            InfoRow(label: "Battery State", value: "\(getBatteryState())")
        }
        .padding()
        .onAppear {
            logger.info("BatteryInfoView appeared. Battery Level: \(Int(UIDevice.current.batteryLevel * 100))%")
        }
    }

    func getBatteryState() -> String {
        switch UIDevice.current.batteryState {
        case .unknown:
            logger.warning("Battery state unknown.")
            return "Unknown"
        case .unplugged: return "Unplugged"
        case .charging: return "Charging"
        case .full: return "Full"
        @unknown default:
            logger.error("Unexpected battery state.")
            return "Unknown"
        }
    }
}
