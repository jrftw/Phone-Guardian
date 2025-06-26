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
            VStack(alignment: .leading, spacing: 24) {
                // MARK: Device Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Device Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        NavigationLink(destination: DetailediPhoneView()) {
                            DeviceCategoryRow(title: "iPhones", icon: "iphone")
                        }
                        NavigationLink(destination: DetailediPadView()) {
                            DeviceCategoryRow(title: "iPads", icon: "ipad")
                        }
                        NavigationLink(destination: DetailedMacView()) {
                            DeviceCategoryRow(title: "Macs", icon: "laptopcomputer")
                        }
                        NavigationLink(destination: DetailedVisionProView()) {
                            DeviceCategoryRow(title: "Vision Pro", icon: "visionpro")
                        }
                    }
                    .padding(.horizontal)
                }
                // MARK: Extra Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Device Information")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        InfoRow(label: "Advertising ID (IDFA)", value: advertisingID)
                        InfoRow(label: "Vendor ID (IDFV)", value: vendorID)
                        InfoRow(label: "IP Address", value: ipAddress)
                        InfoRow(label: "UDID", value: udid)
                        InfoRow(label: "Model Number", value: modelNumber)
                        InfoRow(label: "Serial Number", value: serialNumber)
                        InfoRow(label: "EID", value: eid)
                        InfoRow(label: "IMEI", value: imei)
                        InfoRow(label: "ICCID", value: iccid)
                        InfoRow(label: "IMEI2", value: imei2)
                        InfoRow(label: "SEID", value: seid)
                        InfoRow(label: "Modem Firmware", value: modemFirmware)
                    }
                    .padding(.horizontal)
                }
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
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
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
