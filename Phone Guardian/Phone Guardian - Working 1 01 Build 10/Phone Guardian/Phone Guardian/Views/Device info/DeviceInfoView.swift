import SwiftUI
import CoreTelephony
import AVFoundation
import os

struct DeviceInfoView: View {
    // MARK: - Properties
    private let logger = Logger(subsystem: "com.phoneguardian.deviceinfo", category: "DeviceInfoView")
    @AppStorage("temperatureMetric") private var temperatureMetric: String = "Celsius"
    @AppStorage("enableLogging") private var enableLogging: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Device Information")
                .font(.title2)
                .bold()

            Group {
                InfoRow(label: "Multitasking", value: isMultitaskingSupported() ? "✔︎" : "✘")
                InfoRow(label: "Apple Pencil Supported", value: isApplePencilSupported() ? "✔︎" : "✘")
                InfoRow(label: "Physical SIM Supported", value: isSIMSupported() ? "✔︎" : "✘")
                InfoRow(label: "eSIM Supported", value: isESIMSupported() ? "✔︎" : "✘")
                InfoRow(label: "Headphones Attached", value: isHeadphonesAttached() ? "✔︎" : "✘")
                InfoRow(label: "Satellite Supported", value: isSatelliteSupported() ? "✔︎" : "✘")
                InfoRow(label: "Dynamic Island", value: isDynamicIslandAvailable() ? "✔︎" : "✘")
                InfoRow(label: "5G Network Supported", value: is5GSupported() ? "✔︎" : "✘")
                InfoRow(label: "4G Network Supported", value: is4GSupported() ? "✔︎" : "✘")
                InfoRow(label: "3G Network Supported", value: is3GSupported() ? "✔︎" : "✘")
                InfoRow(label: "2G Network Supported", value: is2GSupported() ? "✔︎" : "✘")
                InfoRow(label: "Port Type", value: getPortType())
                InfoRow(label: "Model Name", value: getDeviceModelName())
                InfoRow(label: "Model Code", value: getDeviceModelCode())
                InfoRow(label: "O.S", value: UIDevice.current.systemVersion)
                InfoRow(label: "Temperature", value: formattedTemperature())
                    .foregroundColor(getTemperatureColor(for: getDeviceTemperature()))
                InfoRow(label: "Phone Uptime", value: getUptime())
                InfoRow(label: "Last Reboot", value: getLastReboot())
                InfoRow(label: "Carrier Lock", value: isCarrierLocked() ? "Locked" : "Unlocked")
                InfoRow(label: "Carrier Information", value: getCarrierInfo())
            }
        }
        .padding()
        .onAppear {
            logInfo("DeviceInfoView loaded")
        }
    }

    // MARK: - Helper Functions
    func isMultitaskingSupported() -> Bool {
        UIDevice.current.isMultitaskingSupported
    }

    func isApplePencilSupported() -> Bool {
        UIDevice.current.model.contains("iPad")
    }

    func isSIMSupported() -> Bool {
        CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.count ?? 0 > 0
    }

    func isESIMSupported() -> Bool {
        CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.values.contains { $0.allowsVOIP } ?? false
    }

    func isHeadphonesAttached() -> Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains { $0.portType == .headphones }
    }

    func isSatelliteSupported() -> Bool {
        let supportedModels = [
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4", // iPhone 16 Series
            "iPhone16,1", "iPhone16,2", "iPhone16,3", "iPhone16,4", // iPhone 16 Series
            "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", // iPhone 15 Series
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5"  // iPhone 14 Series
        ]
        return supportedModels.contains(getDeviceModelCode())
    }

    func isDynamicIslandAvailable() -> Bool {
        let supportedModels = [
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4", // iPhone 16 Series
            "iPhone16,1", "iPhone16,2", "iPhone16,3", "iPhone16,4", // iPhone 16 Series
            "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5", // iPhone 15 Series
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5"  // iPhone 14 Series
        ]
        return supportedModels.contains(getDeviceModelCode())
    }

    func is5GSupported() -> Bool {
        true
    }

    func is4GSupported() -> Bool {
        true
    }

    func is3GSupported() -> Bool {
        false
    }

    func is2GSupported() -> Bool {
        false
    }

    func getPortType() -> String {
        "USB-C"
    }

    func getDeviceModelName() -> String {
        let modelCode = getDeviceModelCode()
        let deviceModel = ModelMapper.mapModelCodeToDeviceModel(modelCode)
        return deviceModel.modelName
    }

    func getDeviceModelCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        } ?? "Unknown"
    }

    func formattedTemperature() -> String {
        let temp = getDeviceTemperature()
        return temperatureMetric == "Celsius" ? "\(temp)°C" : "\((temp * 9/5) + 32)°F"
    }

    func getTemperatureColor(for temp: Double) -> Color {
        switch temp {
        case ..<30: return .green
        case 30..<40: return .yellow
        default: return .red
        }
    }

    func getDeviceTemperature() -> Double {
        Double.random(in: 20...45)
    }

    func getUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / (3600 * 24)
        let hours = (Int(uptime) % (3600 * 24)) / 3600
        return "\(days)d \(hours)h"
    }

    func getLastReboot() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let bootDate = Date().addingTimeInterval(-uptime)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: bootDate)
    }

    func isCarrierLocked() -> Bool {
        false
    }

    func getCarrierInfo() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carriers = networkInfo.serviceSubscriberCellularProviders?.values.map {
            "\($0.carrierName ?? "Unknown") (\($0.isoCountryCode ?? "N/A"))"
        } ?? ["No SIM"]
        return carriers.joined(separator: ", ")
    }

    // MARK: - Logging
    func logInfo(_ message: String) {
        if enableLogging {
            logger.info("\(message)")
        }
    }
}
