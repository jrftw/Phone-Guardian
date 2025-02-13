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
    
    // MARK: Body
    var body: some View {
        NavigationView {
            List {
                // MARK: Device Categories
                Section(header: Text("Device Categories").font(.headline)) {
                    NavigationLink("View iPhones", destination: DetailediPhoneView())
                    NavigationLink("View iPads", destination: DetailediPadView())
                    NavigationLink("View Macs", destination: DetailedMacView())
                    NavigationLink("View Vision Pro", destination: DetailedVisionProView())
                }
                
                // MARK: Extra Info
                Section(header: Text("Extra Info").font(.headline)) {
                    Text("Advertising ID (IDFA): \(advertisingID)")
                    Text("Vendor ID (IDFV): \(vendorID)")
                    Text("IP ADDRESS: \(ipAddress)")
                    Text("UDID: \(udid)")
                    Text("Model Number: \(modelNumber)")
                    Text("Serial Number: \(serialNumber)")
                    Text("EID: \(eid)")
                    Text("IMEI: \(imei)")
                    Text("ICCID: \(iccid)")
                    Text("IMEI2: \(imei2)")
                    Text("SEID: \(seid)")
                    Text("Modem Firm ware: \(modemFirmware)")
                }
            }
            .navigationTitle("Detailed Device Info")
            .onAppear {
                Logger(subsystem: "com.phoneguardian.detaileddeviceinfo", category: "DetailedDeviceInfoView")
                    .info("Loaded DetailedDeviceInfoView")
                
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
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures full screen on iPad
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
