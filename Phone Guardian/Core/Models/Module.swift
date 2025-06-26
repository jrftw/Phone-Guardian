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
                .previewCardStyle()
        case "BatteryInfoView":
            BatteryInfoView()
                .previewCardStyle()
        case "CPUInfoView":
            CPUInfoView()
                .previewCardStyle()
        case "RAMInfoView":
            RAMInfoView()
                .previewCardStyle()
        case "StorageInfoView":
            StorageInfoView()
                .previewCardStyle()
        case "NetworkInfoView":
            NetworkInfoView()
                .previewCardStyle()
        case "SensorInfoView":
            SensorInfoView()
                .previewCardStyle()
        case "DisplayInfoView":
            DisplayInfoView()
                .previewCardStyle()
        case "CameraInfoView":
            CameraInfoView()
                .previewCardStyle()
        case "HealthCheckView":
            HealthCheckView()
                .previewCardStyle()
        default:
            Text("Unknown Module")
                .previewCardStyle()
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
