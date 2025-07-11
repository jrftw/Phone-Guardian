import UIKit
import CoreTelephony
import os

struct DeviceCapabilities {
    private static let logger = Logger(subsystem: "com.phoneguardian.devicecapabilities", category: "DeviceCapabilities")
    private static var hasLoggedDeviceModel = false

    // MARK: - Apple Intelligence Support
    static func isAppleIntelligenceSupported() -> Bool {
        let supportedModels = [
            // iPhones
            "iPhone15,1", "iPhone15,2", "iPhone15,3",
            "iPhone16,1", "iPhone16,2", "iPhone16,3",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",
            // iPads
            "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7",
            "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11",
            "iPad14,1", "iPad14,2",
            "iPad15,1", "iPad15,2", "iPad15,3", "iPad15,4", "iPad15,5", "iPad15,6",
            "iPad16,1", "iPad16,2",
            // Macs (Apple Silicon)
            "MacBookAir10,1", "MacBookAir10,2", "MacBookAir10,3", "MacBookAir15,1", "MacBookAir15,2",
            "MacBookPro17,1", "MacBookPro18,1", "MacBookPro18,2", "MacBookPro18,3", "MacBookPro18,4",
            "MacBookPro18,5", "MacBookPro18,6", "MacBookPro18,7", "MacBookPro18,8", "MacBookPro18,9",
            "MacBookPro18,10", "MacBookPro18,11",
            "Mac14,2", "Mac14,3", "Mac14,4", "Mac14,5", "Mac14,6", "Mac14,15", "Mac14,16",
            "Mac15,1", "Mac15,2", "Mac15,3", "Mac15,4", "Mac15,5", "Mac15,6",
            "Mac14,7", "Mac14,8", "Mac14,9", "Mac14,10", "Mac14,11", "Mac14,12",
            "Mac14,17", "Mac14,18", "Mac14,19", "Mac14,20", "Mac14,21", "Mac14,22", "Mac14,23", "Mac14,24",
            "Mac15,7", "Mac15,8", "Mac15,9", "Mac15,10", "Mac15,11", "Mac15,12", "Mac15,13", "Mac15,14"
        ]
        let isSupported = supportedModels.contains(getDeviceModelCode())
        logOnce(message: "Apple Intelligence Supported: \(isSupported)")
        return isSupported
    }

    // MARK: - Satellite Support
    static func isSatelliteSupported() -> Bool {
        let supportedModels = [
            "iPhone14,2", "iPhone14,3", "iPhone14,5", "iPhone14,6",
            "iPhone15,1", "iPhone15,2", "iPhone15,3",
            "iPhone16,1", "iPhone16,2", "iPhone16,3",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4"
        ]
        let isSupported = supportedModels.contains(getDeviceModelCode())
        logOnce(message: "Satellite Supported: \(isSupported)")
        return isSupported
    }

    // MARK: - Network Support
    static func is5GSupported() -> Bool {
        let supportedDevices = [
            "iPhone12,1", "iPhone12,3", "iPhone12,5", "iPhone12,8",
            "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4",
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5",
            "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5",
            "iPhone16,1", "iPhone16,2", "iPhone16,3", "iPhone16,4",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",
            "iPad13,1", "iPad13,2", "iPad13,4", "iPad13,5", "iPad14,1", "iPad14,2"
        ]
        if let modelIdentifier = getDeviceModelIdentifier() {
            if supportedDevices.contains(modelIdentifier) {
                logOnce(message: "5G Supported: true (Device Model)")
                return true
            }
        }
        let networkInfo = CTTelephonyNetworkInfo()
        if let radioTechnologies = networkInfo.serviceCurrentRadioAccessTechnology?.values {
            let isSupported = radioTechnologies.contains {
                $0 == CTRadioAccessTechnologyNR || $0 == CTRadioAccessTechnologyNRNSA
            }
            logOnce(message: "5G Supported: \(isSupported) (Radio Access)")
            return isSupported
        }
        logOnce(message: "5G Supported: false")
        return false
    }

    static func is4GSupported() -> Bool {
        let supportedDevices = [
            "iPhone7,2", "iPhone7,1",
            "iPhone8,1", "iPhone8,2",
            "iPhone8,4",
            "iPhone9,1", "iPhone9,2", "iPhone9,3", "iPhone9,4",
            "iPhone10,1", "iPhone10,2", "iPhone10,3", "iPhone10,4", "iPhone10,5", "iPhone10,6",
            "iPhone11,8", "iPhone11,2", "iPhone11,6", "iPhone11,4",
            "iPhone12,1", "iPhone12,3", "iPhone12,5",
            "iPhone12,8",
            "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4",
            "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5",
            "iPhone15,2", "iPhone15,3", "iPhone15,4", "iPhone15,5",
            "iPhone16,1", "iPhone16,2", "iPhone16,3", "iPhone16,4",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",
            "iPad13,1", "iPad13,2", "iPad13,4", "iPad13,5", "iPad14,1", "iPad14,2"
        ]
        if let modelIdentifier = getDeviceModelIdentifier() {
            if supportedDevices.contains(modelIdentifier) {
                logOnce(message: "4G Supported: true (Device Model)")
                return true
            }
        }
        let networkInfo = CTTelephonyNetworkInfo()
        if let radioTechnologies = networkInfo.serviceCurrentRadioAccessTechnology?.values {
            let isSupported = radioTechnologies.contains { $0 == CTRadioAccessTechnologyLTE }
            logOnce(message: "4G Supported: \(isSupported) (Radio Access)")
            return isSupported
        }
        logOnce(message: "4G Supported: false")
        return false
    }

    static func is3GSupported() -> Bool {
        let networkInfo = CTTelephonyNetworkInfo()
        if let radioTechnologies = networkInfo.serviceCurrentRadioAccessTechnology?.values {
            let isSupported = radioTechnologies.contains {
                $0 == CTRadioAccessTechnologyWCDMA ||
                $0 == CTRadioAccessTechnologyHSDPA ||
                $0 == CTRadioAccessTechnologyHSUPA ||
                $0 == CTRadioAccessTechnologyCDMA1x ||
                $0 == CTRadioAccessTechnologyCDMAEVDORev0 ||
                $0 == CTRadioAccessTechnologyCDMAEVDORevA ||
                $0 == CTRadioAccessTechnologyCDMAEVDORevB ||
                $0 == CTRadioAccessTechnologyeHRPD
            }
            logOnce(message: "3G Supported: \(isSupported)")
            return isSupported
        }
        logOnce(message: "3G Supported: false")
        return false
    }

    // MARK: - Port Type
    static func getPortType() -> String {
        let usbCModels = [
            "iPhone15,1", "iPhone15,2", "iPhone15,3",
            "iPhone16,1", "iPhone16,2", "iPhone16,3",
            "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4"
        ]
        let portType = usbCModels.contains(getDeviceModelCode()) ? "USB-C" : "Lightning"
        logOnce(message: "Port Type: \(portType)")
        return portType
    }

    // MARK: - Device Model Code
    static func getDeviceModelCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) { ptr in
                String(validatingUTF8: ptr)
            }
        }
        return modelCode ?? "Unknown"
    }

    static func getDeviceModelIdentifier() -> String? {
        return getDeviceModelCode()
    }

    // MARK: - Log Once
    private static func logOnce(message: String) {
        if !hasLoggedDeviceModel {
            logger.info("\(message)")
            hasLoggedDeviceModel = true
        }
    }
}
