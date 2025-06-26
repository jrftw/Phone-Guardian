//
//  DataSent.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/5/24.
//


import Foundation

struct DataSent {
    static func getWiFiDataSent() -> UInt64 {
        return getDataSent(for: ["en0"])
    }

    static func getMobileDataSent() -> UInt64 {
        return getDataSent(for: ["pdp_ip0", "pdp_ip1", "pdp_ip2", "pdp_ip3"])
    }

    private static func getDataSent(for interfaces: [String]) -> UInt64 {
        var totalSent: UInt64 = 0
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0 else { return 0 }
        var ptr = ifaddr
        while ptr != nil {
            if let interface = ptr?.pointee,
               let name = String(cString: interface.ifa_name, encoding: .utf8),
               interfaces.contains(name),
               let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self) {
                totalSent += UInt64(data.pointee.ifi_obytes)
            }
            ptr = ptr?.pointee.ifa_next
        }
        freeifaddrs(ifaddr)
        return totalSent
    }
}