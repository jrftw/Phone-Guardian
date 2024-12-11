// DeviceInfoView.swift

import SwiftUI
import CoreTelephony
import AVFoundation
import os

struct DeviceInfoView: View {
    @AppStorage("temperatureMetric") private var temperatureMetric: String = "Fahrenheit"
    @AppStorage("enableLogging") private var enableLogging: Bool = false
    @State private var thermalTemperature: Int = 75
    @State private var carrierLocked: Bool = false
    @State private var showingDetailedInfo = false
    @State private var showingAd = false
    @State private var shouldShowDetailedView = false
    @State private var temperatureTimer: Timer?
    private let logger = Logger(subsystem: "com.phoneguardian.deviceinfo", category: "DeviceInfoView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Device Information")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "Apple Intelligence Supported", value: DeviceCapabilities.isAppleIntelligenceSupported() ? "✔︎" : "✘")
                InfoRow(label: "Multitasking", value: isMultitaskingSupported() ? "✔︎" : "✘")
                InfoRow(label: "Apple Pencil Supported", value: isApplePencilSupported() ? "✔︎" : "✘")
                InfoRow(label: "Physical SIM Supported", value: isSIMSupported() ? "✔︎" : "✘")
                InfoRow(label: "eSIM Supported", value: isESIMSupported() ? "✔︎" : "✘")
                InfoRow(label: "Headphones Attached", value: isHeadphonesAttached() ? "✔︎" : "✘")
                InfoRow(label: "Satellite Supported", value: DeviceCapabilities.isSatelliteSupported() ? "✔︎" : "✘")
                InfoRow(label: "5G Network Supported", value: DeviceCapabilities.is5GSupported() ? "✔︎" : "✘")
                InfoRow(label: "4G Network Supported", value: DeviceCapabilities.is4GSupported() ? "✔︎" : "✘")
                InfoRow(label: "3G Network Supported", value: DeviceCapabilities.is3GSupported() ? "✔︎" : "✘")
                InfoRow(label: "Port Type", value: DeviceCapabilities.getPortType())
                InfoRow(label: "Model Name", value: getDeviceModelName())
                InfoRow(label: "Model Code", value: DeviceCapabilities.getDeviceModelCode())
                InfoRow(label: "O.S", value: UIDevice.current.systemVersion)
                InfoRow(label: "Temperature", value: "\(thermalTemperature)°F")
                    .foregroundColor(getThermalColor(for: thermalTemperature))
                InfoRow(label: "Carrier Lock", value: carrierLocked ? "Locked" : "Unlocked")
                InfoRow(label: "Phone Uptime", value: getUptime())
                InfoRow(label: "Last Reboot", value: getLastReboot())
                InfoRow(label: "Carrier Information", value: getCarrierInfo())
            }

            Button(action: handleDetailedInfoAction) {
                Text("View Detailed Device Information")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            logInfo("DeviceInfoView loaded")
            startTemperatureUpdates()
            updateCarrierLockStatus()
        }
        .onDisappear {
            stopTemperatureUpdates()
        }
        .sheet(isPresented: $showingDetailedInfo) {
            DetailedDeviceInfoView()
        }
        .fullScreenCover(isPresented: $showingAd) {
            VideoAdView(onAdDismissed: { _ in handleAdDismissed() })
        }
    }

    func handleDetailedInfoAction() {
        if IAPManager.shared.hasGoldAccess || IAPManager.shared.hasToolsSubscription {
            showingDetailedInfo = true
        } else {
            showingAd = true
            shouldShowDetailedView = true
        }
    }

    func handleAdDismissed() {
        if shouldShowDetailedView {
            showingDetailedInfo = true
        }
        shouldShowDetailedView = false
    }

    func getDeviceModelName() -> String {
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        return ModelMapper.mapModelCodeToDeviceModel(modelCode).modelName
    }

    func getThermalColor(for temperature: Int) -> Color {
        switch temperature {
        case ..<80:
            return .green
        case 80..<90:
            return .yellow
        case 90..<100:
            return .orange
        default:
            return .red
        }
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

    func getCarrierInfo() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carriers = networkInfo.serviceSubscriberCellularProviders?.values {
            let carrierNames = carriers.compactMap { $0.carrierName }
            return carrierNames.isEmpty ? "No SIM" : carrierNames.joined(separator: ", ")
        } else {
            return "No SIM"
        }
    }

    func updateCarrierLockStatus() {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carriers = networkInfo.serviceSubscriberCellularProviders?.values {
            carrierLocked = carriers.contains { $0.mobileCountryCode == nil }
        } else {
            carrierLocked = false
        }
    }

    func startTemperatureUpdates() {
        temperatureTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            thermalTemperature = TemperatureManager.shared.getDeviceTemperature()
        }
    }

    func stopTemperatureUpdates() {
        temperatureTimer?.invalidate()
        temperatureTimer = nil
    }

    func logInfo(_ message: String) {
        if enableLogging {
            logger.info("\(message)")
        }
    }

    func isMultitaskingSupported() -> Bool {
        UIDevice.current.isMultitaskingSupported
    }

    func isApplePencilSupported() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    func isSIMSupported() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceSubscriberCellularProviders?.count ?? 0 > 0
    }

    func isESIMSupported() -> Bool {
        let supportedDevices = [
            "iPhone11,2", "iPhone11,4", "iPhone11,6", "iPhone11,8",
            "iPhone12,1", "iPhone12,3", "iPhone12,5",
            "iPhone12,8",
            "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4",
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5",
            "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5",
            "iPhone16,1", "iPhone16,2", "iPhone16,3", "iPhone16,4",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",
            "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4",
            "iPad11,1", "iPad11,2",
            "iPad11,3", "iPad11,4",
            "iPad7,11", "iPad7,12",
            "Watch3,3", "Watch3,4", "Watch4,1", "Watch4,2",
            "Watch5,1", "Watch5,2", "Watch6,1", "Watch6,2",
            "WatchSE,1", "WatchSE,2",
            "WatchUltra1,1",
            "MacBookPro18,1", "MacBookPro18,2"
        ]
        if let modelIdentifier = getDeviceModelIdentifier() {
            if supportedDevices.contains(modelIdentifier) {
                logOnce(message: "eSIM Supported: true (Device Model)")
                return true
            }
        }
        if #available(iOS 12.1, *) {
            let provisioning = CTCellularPlanProvisioning()
            let supportsESIM = provisioning.supportsCellularPlan()
            logOnce(message: "eSIM Supported: \(supportsESIM) (System Check)")
            return supportsESIM
        }
        logOnce(message: "eSIM Supported: false")
        return false
    }

    func getDeviceModelIdentifier() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        return modelCode
    }

    func logOnce(message: String) {
        if enableLogging {
            logger.info("\(message)")
        }
    }

    func isHeadphonesAttached() -> Bool {
        let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
        return outputs.contains { output in
            output.portType == .headphones ||
            output.portType == .bluetoothA2DP ||
            output.portType == .bluetoothLE ||
            output.portType == .bluetoothHFP ||
            output.portType == .usbAudio
        }
    }
}
