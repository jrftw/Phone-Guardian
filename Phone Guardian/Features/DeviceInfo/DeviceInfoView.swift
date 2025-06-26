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
    @State private var temperatureTimer: Timer?
    @State private var showingDetailedInfo = false
    private let logger = Logger(subsystem: "com.phoneguardian.deviceinfo", category: "DeviceInfoView")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Device Capabilities Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Device Capabilities", systemImage: "info.circle")
                            .font(.headline)
                            .padding(.bottom, 4)
                        InfoRow(label: "Apple Intelligence Supported", value: DeviceCapabilities.isAppleIntelligenceSupported() ? "✔︎" : "✘")
                        InfoRow(label: "Multitasking", value: isMultitaskingSupported() ? "✔︎" : "✘")
                        InfoRow(label: "Apple Pencil Supported", value: isApplePencilSupported() ? "✔︎" : "✘")
                        InfoRow(label: "Physical SIM Supported", value: isSIMSupported() ? "✔︎" : "✘")
                        InfoRow(label: "eSIM Supported", value: isESIMSupported() ? "✔︎" : "✘")
                        InfoRow(label: "Dual SIM Supported", value: isDualSIMSupported() ? "✔︎" : "✘")
                        InfoRow(label: "SIM Active", value: isSIMActive() ? "✔︎" : "✘")
                        InfoRow(label: "eSIM Active", value: isESIMActive() ? "✔︎" : "✘")
                        InfoRow(label: "Dual SIM Active", value: isDualSIMActive() ? "✔︎" : "✘")
                        InfoRow(label: "Headphones Attached", value: isHeadphonesAttached() ? "✔︎" : "✘")
                        InfoRow(label: "Satellite Supported", value: DeviceCapabilities.isSatelliteSupported() ? "✔︎" : "✘")
                        InfoRow(label: "5G Network Supported", value: DeviceCapabilities.is5GSupported() ? "✔︎" : "✘")
                        InfoRow(label: "4G Network Supported", value: DeviceCapabilities.is4GSupported() ? "✔︎" : "✘")
                        InfoRow(label: "3G Network Supported", value: DeviceCapabilities.is3GSupported() ? "✔︎" : "✘")
                        InfoRow(label: "Port Type", value: DeviceCapabilities.getPortType())
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    // Device Model & OS Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Device Model & OS", systemImage: "iphone")
                            .font(.headline)
                            .padding(.bottom, 4)
                        InfoRow(label: "Model Name", value: getDeviceModelName())
                        InfoRow(label: "Model Code", value: DeviceCapabilities.getDeviceModelCode())
                        InfoRow(label: "O.S", value: UIDevice.current.systemVersion)
                        InfoRow(label: "Temperature", value: "\(thermalTemperature)°\(temperatureMetric == "Fahrenheit" ? "F" : "C")")
                        InfoRow(label: "Carrier Lock", value: carrierLocked ? "Locked" : "Unlocked")
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    // Uptime & Carrier Section
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Uptime & Carrier", systemImage: "clock")
                            .font(.headline)
                            .padding(.bottom, 4)
                        InfoRow(label: "Phone Uptime", value: getUptime())
                        InfoRow(label: "Last Reboot", value: getLastReboot())
                        InfoRow(label: "Carrier Information", value: getCarrierInfo())
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    
                    Button(action: { showingDetailedInfo = true }) {
                        Text("View Detailed Device Information")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Device Info")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("DeviceInfoView appeared.")
            startTemperatureMonitoring()
            checkCarrierLock()
        }
        .onDisappear {
            temperatureTimer?.invalidate()
        }
        .sheet(isPresented: $showingDetailedInfo) {
            if #available(iOS 16.0, *) {
                DetailedDeviceInfoSheet(showingDetailedInfo: $showingDetailedInfo)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            } else {
                DetailedDeviceInfoSheet(showingDetailedInfo: $showingDetailedInfo)
            }
        }
    }
    
    // MARK: - Info Logic
    func getDeviceModelName() -> String {
        let modelCode = DeviceCapabilities.getDeviceModelCode()
        return ModelMapper.mapModelCodeToDeviceModel(modelCode).modelName
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
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders?.values else { return false }
            return carriers.contains { carrier in
                carrier.isoCountryCode != nil && carrier.carrierName != nil
            }
        }
        return false
    }
    func isDualSIMSupported() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders else { return false }
            return carriers.count > 1
        }
        return false
    }
    func isSIMActive() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders?.values else { return false }
            return carriers.contains { carrier in
                carrier.isoCountryCode != nil && carrier.carrierName != nil
            }
        } else {
            return networkInfo.subscriberCellularProvider?.carrierName != nil
        }
    }
    func isESIMActive() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders?.values else { return false }
            return carriers.contains { carrier in
                carrier.carrierName?.contains("eSIM") ?? false ||
                carrier.carrierName?.contains("Embedded") ?? false
            }
        }
        return false
    }
    func isDualSIMActive() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders?.values else { return false }
            let hasPhysicalSIM = carriers.contains { carrier in
                !(carrier.carrierName?.contains("eSIM") ?? false) &&
                !(carrier.carrierName?.contains("Embedded") ?? false)
            }
            let hasESIM = carriers.contains { carrier in
                carrier.carrierName?.contains("eSIM") ?? false ||
                carrier.carrierName?.contains("Embedded") ?? false
            }
            return hasPhysicalSIM && hasESIM
        }
        return false
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
    
    private func startTemperatureMonitoring() {
        temperatureTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            updateTemperature()
        }
        updateTemperature()
    }
    private func updateTemperature() {
        // Simulate temperature reading (replace with actual temperature monitoring)
        thermalTemperature = Int.random(in: 70...85)
    }
    private func checkCarrierLock() {
        // Simulate carrier lock check (replace with actual carrier lock detection)
        carrierLocked = Bool.random()
    }
}

struct DetailedDeviceInfoSheet: View {
    @Binding var showingDetailedInfo: Bool
    var body: some View {
        NavigationView {
            DetailedDeviceInfoView()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Done") {
                    showingDetailedInfo = false
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
