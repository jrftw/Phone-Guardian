import SwiftUI
import CoreTelephony
import AVFoundation
import SystemConfiguration.CaptiveNetwork

struct DeviceInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("DEVICE")
                .font(.title2)
                .bold()

            InfoRow(label: "Jailbreak Status", value: isDeviceJailbroken() ? "✔︎" : "✘")
            InfoRow(label: "Multitasking Supported", value: isMultitaskingSupported() ? "✔︎" : "✘")
            InfoRow(label: "Apple Pencil Supported", value: isApplePencilSupported() ? "✔︎" : "✘")
            InfoRow(label: "eSIM Supported", value: isESIMSupported() ? "✔︎" : "✘")
            InfoRow(label: "SIM Supported", value: isSIMSupported() ? "✔︎" : "✘")
            InfoRow(label: "Carrier Lock", value: isCarrierLocked() ? "Locked" : "Unlocked")
            InfoRow(label: "Carrier Info", value: getCarrierInfo())
            InfoRow(label: "Port Type", value: getPortType())
            InfoRow(label: "Model Name", value: UIDevice.current.model)
            InfoRow(label: "iOS Version", value: UIDevice.current.systemVersion)
            InfoRow(label: "Uptime", value: getUptime())
            InfoRow(label: "Headphones Attached", value: isHeadphonesAttached() ? "✔︎" : "✘")
            InfoRow(label: "5G Supported", value: is5GSupported() ? "✔︎" : "✘")
            InfoRow(label: "4G Supported", value: is4GSupported() ? "✔︎" : "✘")
            InfoRow(label: "3G Supported", value: is3GSupported() ? "✔︎" : "✘")
            InfoRow(label: "2G Supported", value: is2GSupported() ? "✔︎" : "✘")
            InfoRow(label: "Satellite Supported", value: isSatelliteSupported() ? "✔︎" : "✘")
            InfoRow(label: "Dynamic Island", value: isDynamicIslandAvailable() ? "✔︎" : "✘")
            InfoRow(label: "Model Code", value: getDeviceModelCode())
            InfoRow(label: "Device Temperature", value: getDeviceTemperature())
            InfoRow(label: "Last Reboot", value: getLastReboot())
        }
        .padding()
    }

    // MARK: - Device Details and Helpers

    func isDeviceJailbroken() -> Bool {
        let paths = ["/Applications/Cydia.app", "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash"]
        if paths.contains(where: { FileManager.default.fileExists(atPath: $0) }) {
            return true
        }
        return FileManager.default.isWritableFile(atPath: "/private/")
    }

    func isMultitaskingSupported() -> Bool {
        return UIDevice.current.isMultitaskingSupported
    }

    func isApplePencilSupported() -> Bool {
        let supportedModels = ["iPad", "iPad Pro"]
        return supportedModels.contains(UIDevice.current.model)
    }

    func isESIMSupported() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        guard let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value else { return false }
        return carrier.allowsVOIP
    }

    func isSIMSupported() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceSubscriberCellularProviders?.count ?? 0 > 0
    }

    func isCarrierLocked() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value {
            return carrier.mobileNetworkCode == nil || carrier.mobileCountryCode == nil
        }
        return true
    }

    func getCarrierInfo() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carriers = networkInfo.serviceSubscriberCellularProviders?.values.map { carrier in
            "\(carrier.carrierName ?? "Unknown") (\(carrier.isoCountryCode?.uppercased() ?? "N/A"))"
        } ?? ["No SIM"]
        return carriers.joined(separator: " | ")
    }

    func getPortType() -> String {
        if let deviceInfo = getHardwareDetails(), deviceInfo.contains("Lightning") {
            return "Lightning"
        } else {
            return "USB-C"
        }
    }

    func getUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime) / (3600 * 24)
        let hours = (Int(uptime) % (3600 * 24)) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        return "\(days)d \(hours)h \(minutes)m"
    }

    func isHeadphonesAttached() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.currentRoute.outputs.contains { $0.portType == .headphones }
    }

    func is5GSupported() -> Bool {
        let currentRadio = CTTelephonyNetworkInfo().currentRadioAccessTechnology ?? ""
        return currentRadio.contains("NR")
    }

    func is4GSupported() -> Bool {
        let currentRadio = CTTelephonyNetworkInfo().currentRadioAccessTechnology ?? ""
        return currentRadio.contains("LTE")
    }

    func is3GSupported() -> Bool {
        let currentRadio = CTTelephonyNetworkInfo().currentRadioAccessTechnology ?? ""
        return ["CTRadioAccessTechnologyHSDPA", "CTRadioAccessTechnologyWCDMA"].contains(currentRadio)
    }

    func is2GSupported() -> Bool {
        let currentRadio = CTTelephonyNetworkInfo().currentRadioAccessTechnology ?? ""
        return ["CTRadioAccessTechnologyEdge", "CTRadioAccessTechnologyGPRS"].contains(currentRadio)
    }

    func isSatelliteSupported() -> Bool {
        // Extend logic based on specific models
        return false
    }

    func isDynamicIslandAvailable() -> Bool {
        let dynamicIslandModels = ["iPhone 14 Pro", "iPhone 15 Pro"]
        return dynamicIslandModels.contains(UIDevice.current.name)
    }

    func getDeviceModelCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return modelCode ?? "Unknown"
    }

    func getDeviceTemperature() -> String {
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            return "Normal"
        case .fair:
            return "Elevated"
        case .serious:
            return "High"
        case .critical:
            return "Critical"
        @unknown default:
            return "Unknown"
        }
    }

    func getLastReboot() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let bootDate = Date().addingTimeInterval(-uptime)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: bootDate)
    }

    func getHardwareDetails() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(validatingUTF8: withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1, { $0 })
        }) ?? "Unknown"
    }
}
