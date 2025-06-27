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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Device Capabilities Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Capabilities", icon: "info.circle")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "brain.head.profile", label: "Apple Intelligence", value: DeviceCapabilities.isAppleIntelligenceSupported() ? "Supported" : "Not Supported", iconColor: .blue)
                        ModernInfoRow(icon: "rectangle.stack", label: "Multitasking", value: isMultitaskingSupported() ? "Supported" : "Not Supported", iconColor: .green)
                        ModernInfoRow(icon: "pencil.tip", label: "Apple Pencil", value: isApplePencilSupported() ? "Supported" : "Not Supported", iconColor: .purple)
                        ModernInfoRow(icon: "simcard", label: "Physical SIM", value: isSIMSupported() ? "Supported" : "Not Supported", iconColor: .orange)
                        ModernInfoRow(icon: "simcard.2", label: "eSIM", value: isESIMSupported() ? "Supported" : "Not Supported", iconColor: .cyan)
                        ModernInfoRow(icon: "simcard.2.fill", label: "Dual SIM", value: isDualSIMSupported() ? "Supported" : "Not Supported", iconColor: .indigo)
                        ModernInfoRow(icon: "headphones", label: "Headphones", value: isHeadphonesAttached() ? "Connected" : "Not Connected", iconColor: .pink)
                        ModernInfoRow(icon: "satellite", label: "Satellite", value: DeviceCapabilities.isSatelliteSupported() ? "Supported" : "Not Supported", iconColor: .red)
                        ModernInfoRow(icon: "network", label: "5G Network", value: DeviceCapabilities.is5GSupported() ? "Supported" : "Not Supported", iconColor: .blue)
                        ModernInfoRow(icon: "network", label: "4G Network", value: DeviceCapabilities.is4GSupported() ? "Supported" : "Not Supported", iconColor: .green)
                        ModernInfoRow(icon: "network", label: "3G Network", value: DeviceCapabilities.is3GSupported() ? "Supported" : "Not Supported", iconColor: .orange)
                        ModernInfoRow(icon: "cable.connector", label: "Port Type", value: DeviceCapabilities.getPortType(), iconColor: .gray)
                    }
                }
                .modernCard()
                
                // Device Model & OS Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Model & OS", icon: "iphone")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "iphone", label: "Model Name", value: getDeviceModelName(), iconColor: .blue)
                        ModernInfoRow(icon: "number", label: "Model Code", value: DeviceCapabilities.getDeviceModelCode(), iconColor: .gray)
                        ModernInfoRow(icon: "gear", label: "iOS Version", value: UIDevice.current.systemVersion, iconColor: .green)
                        ModernInfoRow(icon: "thermometer", label: "Temperature", value: "\(thermalTemperature)°\(temperatureMetric == "Fahrenheit" ? "F" : "C")", iconColor: .red)
                        ModernInfoRow(icon: "lock", label: "Carrier Lock", value: carrierLocked ? "Locked" : "Unlocked", iconColor: carrierLocked ? .red : .green)
                    }
                }
                .modernCard()
                
                // Uptime & Carrier Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Uptime & Carrier", icon: "clock")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "timer", label: "Phone Uptime", value: getUptime(), iconColor: .blue)
                        ModernInfoRow(icon: "arrow.clockwise", label: "Last Reboot", value: getLastReboot(), iconColor: .orange)
                        ModernInfoRow(icon: "antenna.radiowaves.left.and.right", label: "Carrier", value: getCarrierInfo(), iconColor: .green)
                    }
                }
                .modernCard()
                
                // Detailed Info Button
                Button(action: { showingDetailedInfo = true }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("View Detailed Device Information")
                    }
                }
                .modernButton(backgroundColor: .blue)
                .padding(.top, 8)
            }
            .padding()
        }
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
        // Get thermal state which is the closest we can get to actual temperature
        let thermalState = ProcessInfo.processInfo.thermalState
        switch thermalState {
        case .nominal:
            thermalTemperature = 25 // Normal operating temperature
        case .fair:
            thermalTemperature = 35 // Slightly elevated
        case .serious:
            thermalTemperature = 45 // Elevated temperature
        case .critical:
            thermalTemperature = 55 // High temperature
        @unknown default:
            thermalTemperature = 30 // Default fallback
        }
    }
    private func checkCarrierLock() {
        // Check if device is carrier locked by examining network restrictions
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let carriers = networkInfo.serviceSubscriberCellularProviders?.values else {
                carrierLocked = false
                return
            }
            
            // Check if any carrier has restrictions that might indicate a lock
            var hasRestrictions = false
            for carrier in carriers {
                let allowsVOIP = carrier.allowsVOIP ?? true
                // Note: supportsDataWhenRoaming is not available on CTCarrier
                // We'll use a simpler check based on available properties
                if !allowsVOIP {
                    hasRestrictions = true
                    break
                }
            }
            
            carrierLocked = hasRestrictions
        } else {
            // For older iOS versions, assume unlocked
            carrierLocked = false
        }
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
