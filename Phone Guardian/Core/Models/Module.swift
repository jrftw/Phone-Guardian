// Module.swift

import SwiftUI

struct Module: Identifiable, Codable {
    var id = UUID()
    let name: String
    let viewName: String
    var isEnabled: Bool
    let description: String
    let iconName: String
    
    @ViewBuilder
    var view: some View {
        switch viewName {
        case "DeviceInfoView":
            DeviceInfoView()
        case "BatteryInfoView":
            BatteryInfoView()
        case "CPUInfoView":
            CPUInfoView()
        case "RAMInfoView":
            RAMInfoView()
        case "StorageInfoView":
            StorageInfoView()
        case "NetworkInfoView":
            NetworkInfoView()
        case "SensorInfoView":
            SensorInfoView()
        case "DisplayInfoView":
            DisplayInfoView()
        case "CameraInfoView":
            CameraInfoView()
        case "HealthCheckView":
            HealthCheckView()
        case "GPUInfoView":
            GPUInfoView()
        case "ThermalInfoView":
            ThermalInfoView()
        case "PrivacyControlView":
            PrivacyControlView()
        default:
            Text("Unknown Module")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
        }
    }
}

extension View {
    func previewCardStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.tertiarySystemBackground))
            )
    }
}
