// Module.swift

import SwiftUI

struct Module: Identifiable, Codable {
    var id = UUID()
    let name: String
    let viewName: String
    var isEnabled: Bool

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
        default:
            Text("Unknown Module")
        }
    }
}
