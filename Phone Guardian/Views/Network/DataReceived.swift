//
//  DataReceived.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/5/24.
//


import Foundation

struct DataReceived {
    static func getWiFiDataReceived() -> UInt64 {
        return getDataReceived(for: ["en0"])
    }

    static func getMobileDataReceived() -> UInt64 {
        return getDataReceived(for: ["pdp_ip0", "pdp_ip1", "pdp_ip2", "pdp_ip3"])
    }

    private static func getDataReceived(for interfaces: [String]) -> UInt64 {
        var totalReceived: UInt64 = 0
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return 0 }
        var ptr = ifaddr
        while ptr != nil {
            if let interface = ptr?.pointee,
               let name = String(cString: interface.ifa_name, encoding: .utf8),
               interfaces.contains(name),
               let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalReceived += UInt64(data.pointee.ifi_ibytes)
            }
            ptr = ptr?.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
        return totalReceived
    }
}