import SwiftUI
import os
import AdSupport
import AppTrackingTransparency
import UIKit
import SystemConfiguration
import Darwin

// MARK: - DetailedDeviceInfoView
struct DetailedDeviceInfoView: View {
    
    // MARK: State Properties
    @State private var advertisingID = "N/A"
    @State private var vendorID = "N/A"
    @State private var ipAddress = "N/A"
    @State private var udid = "N/A"
    @State private var modelNumber = "N/A"
    @State private var serialNumber = "N/A"
    @State private var eid = "N/A"
    @State private var imei = "N/A"
    @State private var iccid = "N/A"
    @State private var imei2 = "N/A"
    @State private var seid = "N/A"
    @State private var modemFirmware = "N/A"
    private let logger = Logger(subsystem: "com.phoneguardian.deviceinfo", category: "DetailedDeviceInfoView")
    
    // MARK: Body
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // MARK: Device Categories
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Categories", icon: "iphone")
                    
                    LazyVStack(spacing: 12) {
                        NavigationLink(destination: DetailediPhoneView()) {
                            DeviceCategoryRow(title: "iPhones", icon: "iphone")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: DetailediPadView()) {
                            DeviceCategoryRow(title: "iPads", icon: "ipad")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: DetailedMacView()) {
                            DeviceCategoryRow(title: "Macs", icon: "laptopcomputer")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: DetailedVisionProView()) {
                            DeviceCategoryRow(title: "Vision Pro", icon: "visionpro")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .modernCard()
                
                // MARK: Advanced Information Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Advanced Information", icon: "gearshape.2")
                    
                    LazyVStack(spacing: 12) {
                        NavigationLink(destination: DeviceLocationInfoView()) {
                            AdvancedInfoRow(title: "Device Location", subtitle: "Track device location and movement", icon: "location")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: DeviceSecurityInfoView()) {
                            AdvancedInfoRow(title: "Device Security", subtitle: "Security status and encryption", icon: "lock.shield")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: DeviceWarrantyInfoView()) {
                            AdvancedInfoRow(title: "Device Warranty", subtitle: "Warranty status and coverage", icon: "checkmark.shield")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: HardwareHealthInfoView()) {
                            AdvancedInfoRow(title: "Hardware Health", subtitle: "Component health and diagnostics", icon: "heart.text.square")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SystemUpdateInfoView()) {
                            AdvancedInfoRow(title: "System Updates", subtitle: "iOS updates and availability", icon: "arrow.clockwise.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SystemLogsInfoView()) {
                            AdvancedInfoRow(title: "System Logs", subtitle: "Device logs and diagnostics", icon: "doc.text")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SignalStrengthInfoView()) {
                            AdvancedInfoRow(title: "Signal Strength", subtitle: "Network signal monitoring", icon: "antenna.radiowaves.left.and.right")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SystemServicesInfoView()) {
                            AdvancedInfoRow(title: "System Services", subtitle: "Background services status", icon: "gearshape")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: BackgroundAppRefreshInfoView()) {
                            AdvancedInfoRow(title: "Background App Refresh", subtitle: "Background refresh settings", icon: "arrow.clockwise")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .modernCard()
                
                // MARK: Extra Info
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Information", icon: "info.circle")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "person.crop.circle", label: "Advertising ID (IDFA)", value: advertisingID, iconColor: .blue)
                        ModernInfoRow(icon: "building.2", label: "Vendor ID (IDFV)", value: vendorID, iconColor: .green)
                        ModernInfoRow(icon: "network", label: "IP Address", value: ipAddress, iconColor: .orange)
                        ModernInfoRow(icon: "number", label: "UDID", value: udid, iconColor: .red)
                        ModernInfoRow(icon: "iphone", label: "Model Number", value: modelNumber, iconColor: .purple)
                        ModernInfoRow(icon: "barcode", label: "Serial Number", value: serialNumber, iconColor: .cyan)
                        ModernInfoRow(icon: "simcard", label: "EID", value: eid, iconColor: .indigo)
                        ModernInfoRow(icon: "antenna.radiowaves.left.and.right", label: "IMEI", value: imei, iconColor: .pink)
                        ModernInfoRow(icon: "simcard.2", label: "ICCID", value: iccid, iconColor: .gray)
                        ModernInfoRow(icon: "antenna.radiowaves.left.and.right", label: "IMEI2", value: imei2, iconColor: .blue)
                        ModernInfoRow(icon: "shield", label: "SEID", value: seid, iconColor: .green)
                        ModernInfoRow(icon: "gear", label: "Modem Firmware", value: modemFirmware, iconColor: .orange)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("DetailedDeviceInfoView appeared.")
            advertisingID = fetchIDFA()
            vendorID = fetchIDFV()
            ipAddress = getIPAddress() ?? "N/A"
            udid = "Not accessible"
            modelNumber = getModelIdentifier()
            serialNumber = "Not accessible"
            eid = "Not accessible"
            imei = "Not accessible"
            iccid = "Not accessible"
            imei2 = "Not accessible"
            seid = "Not accessible"
            modemFirmware = "Not accessible"
            logger.info("Device info loaded: advertisingID=\(advertisingID), vendorID=\(vendorID), ipAddress=\(ipAddress), modelNumber=\(modelNumber)")
        }
    }
}

// MARK: - Supporting Views
struct DeviceCategoryRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Advanced Info Row
struct AdvancedInfoRow: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Helper Functions
extension DetailedDeviceInfoView {
    
    // MARK: IDFA
    private func fetchIDFA() -> String {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return "N/A"
            }
        } else {
            let manager = ASIdentifierManager.shared()
            if manager.isAdvertisingTrackingEnabled {
                return manager.advertisingIdentifier.uuidString
            }
            return "N/A"
        }
    }
    
    // MARK: IDFV
    private func fetchIDFV() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? "N/A"
    }
    
    // MARK: IP Address
    private func getIPAddress() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            if (flags & IFF_UP) == IFF_UP && (flags & IFF_RUNNING) == IFF_RUNNING
                && addr.sa_family == sa_family_t(AF_INET) {
                
                let name = String(cString: ptr.pointee.ifa_name)
                if name == "en0" || name == "pdp_ip0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        ptr.pointee.ifa_addr,
                        socklen_t(addr.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    )
                    addresses.append(String(cString: hostname))
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses.first
    }
    
    // MARK: Model Identifier (closest to "Model Number" accessible)
    private func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.compactMap { value -> String? in
            guard let ascii = value.value as? Int8, ascii != 0 else { return nil }
            return String(UnicodeScalar(UInt8(ascii)))
        }.joined()
        return identifier
    }
}
