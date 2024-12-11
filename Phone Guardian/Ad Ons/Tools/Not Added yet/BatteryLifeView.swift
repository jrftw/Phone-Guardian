// BatteryLifeView.swift

import SwiftUI
import UIKit

struct BatteryLifeView: View {
    @State private var batteryLevel: Float = UIDevice.current.batteryLevel
    @State private var batteryState: UIDevice.BatteryState = UIDevice.current.batteryState
    @State private var batteryHealth: String = "Good"
    @State private var isLowPowerModeEnabled: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Battery icon at the top
            HStack {
                Spacer()
                BatteryIconView(batteryLevel: batteryLevel)
                    .frame(width: 100, height: 50)
                Spacer()
            }
            .padding(.top)

            // Option to enable low power mode
            Toggle(isOn: $isLowPowerModeEnabled) {
                Text("Enable Low Power Mode")
                    .font(.headline)
            }
            .padding(.horizontal)
            .onChange(of: isLowPowerModeEnabled) { newValue in
                setLowPowerMode(enabled: newValue)
            }

            VStack(alignment: .leading, spacing: 10) {
                ToolsStorageInfoRow(label: "Battery Level:", value: "\(Int(batteryLevel * 100))%")
                ToolsStorageInfoRow(label: "Battery State:", value: batteryStateDescription)
                ToolsStorageInfoRow(label: "Battery Health:", value: batteryHealth)
            }
            .padding(.horizontal)

            Divider()
                .padding(.vertical)

            Text("Tips to Improve Battery Life")
                .font(.title3)
                .bold()
                .padding(.horizontal)

            List {
                ForEach(tips, id: \.self) { tip in
                    Text("• \(tip)")
                        .padding(.vertical, 5)
                }
            }
        }
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            updateBatteryInfo()
            NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { _ in
                updateBatteryInfo()
            }
            NotificationCenter.default.addObserver(forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: .main) { _ in
                updateBatteryInfo()
            }
            NotificationCenter.default.addObserver(forName: .NSProcessInfoPowerStateDidChange, object: nil, queue: .main) { _ in
                isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            }
        }
        .onDisappear {
            UIDevice.current.isBatteryMonitoringEnabled = false
            NotificationCenter.default.removeObserver(self)
        }
    }

    private func updateBatteryInfo() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
        batteryHealth = getBatteryHealth()
    }

    private var batteryStateDescription: String {
        switch batteryState {
        case .unknown:
            return "Unknown"
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        @unknown default:
            return "Unknown"
        }
    }

    private func getBatteryHealth() -> String {
        if batteryLevel >= 0.8 {
            return "Good"
        } else if batteryLevel >= 0.5 {
            return "Average"
        } else {
            return "Poor"
        }
    }

    private func setLowPowerMode(enabled: Bool) {
        // Note: There is no public API to programmatically enable Low Power Mode.
        // Attempting to do so can lead to App Store rejection.
        // Instead, we can guide the user to the Settings app.

        if enabled != ProcessInfo.processInfo.isLowPowerModeEnabled {
            let alert = UIAlertController(
                title: "Low Power Mode",
                message: "To change Low Power Mode settings, please go to Settings.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }

    private let tips: [String] = [
        "Update to the latest system software.",
        "Reduce screen brightness.",
        "Use Wi-Fi instead of cellular data.",
        "Turn off Background App Refresh.",
        "Disable Location Services for unnecessary apps.",
        "Enable Low Power Mode.",
        "Avoid extreme temperatures.",
        "Remove unnecessary widgets.",
        "Turn off push email.",
        "Limit app notifications."
    ]
}

struct BatteryIconView: View {
    let batteryLevel: Float

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: 60, height: 25)

            RoundedRectangle(cornerRadius: 2)
                .fill(batteryColor)
                .frame(width: CGFloat(batteryLevel) * 60, height: 25)

            Rectangle()
                .fill(Color.gray)
                .frame(width: 4, height: 10)
                .offset(x: 62, y: 7.5)
        }
    }

    private var batteryColor: Color {
        if batteryLevel > 0.8 {
            return Color.green
        } else if batteryLevel > 0.5 {
            return Color.yellow
        } else {
            return Color.red
        }
    }
}

struct ToolsStorageInfoRow: View {
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
