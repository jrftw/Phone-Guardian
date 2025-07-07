//
//  PacketTunnelProvider.swift
//  InfiLocTunnel
//
//  Created by Kevin Doyle Jr. on 7/7/25.
//

import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.phoneguardian.infiloc.tunnel", category: "PacketTunnel")
    private var isMonitoring = false
    
    // Known location service domains to monitor
    private let locationDomains: [String: String] = [
        // Apple Services
        "gsp-ssl.ls.apple.com": "Find My iPhone",
        "gsp.apple.com": "Find My iPhone",
        "gs-loc.apple.com": "Apple Location Services",
        "location.apple.com": "Apple Location Services",
        
        // Life360
        "api.life360.com": "Life360",
        "api-cloudfront.life360.com": "Life360",
        "location.life360.com": "Life360",
        
        // Snapchat
        "snapchat.com": "Snapchat",
        "api.snapchat.com": "Snapchat",
        
        // WhatsApp
        "g.whatsapp.com": "WhatsApp Live Location",
        "mmg.whatsapp.com": "WhatsApp",
        "media.fada1-1.fna.whatsapp.net": "WhatsApp",
        
        // Google Services
        "maps.googleapis.com": "Google Maps",
        "location.googleapis.com": "Google Location",
        "www.googleapis.com": "Google APIs",
        
        // Facebook/Meta
        "graph.facebook.com": "Facebook Location",
        "api.facebook.com": "Facebook",
        "edge-mqtt.facebook.com": "Facebook",
        
        // Other Common Location Services
        "api.foursquare.com": "Foursquare",
        "api.yelp.com": "Yelp",
        "api.uber.com": "Uber",
        "api.lyft.com": "Lyft",
        "api.here.com": "HERE Maps",
        "api.mapbox.com": "Mapbox",
        "api.openstreetmap.org": "OpenStreetMap"
    ]
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting INFILOC tunnel")
        
        // Configure the tunnel
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // Set up DNS settings to capture DNS queries
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        settings.dnsSettings = dnsSettings
        
        // Set up routing to capture all traffic
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings
        
        // Apply the settings
        setTunnelNetworkSettings(settings) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Failed to set tunnel settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            self.logger.info("Tunnel settings applied successfully")
            self.isMonitoring = true
            self.startPacketProcessing()
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping INFILOC tunnel")
        isMonitoring = false
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    private func startPacketProcessing() {
        guard let packetFlow = self.packetFlow else {
            logger.error("Packet flow not available")
            return
        }
        
        // Start reading packets from the tunnel
        readPacketsFromTunnel(packetFlow: packetFlow)
    }
    
    private func readPacketsFromTunnel(packetFlow: NEPacketTunnelFlow) {
        guard isMonitoring else { return }
        
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self, self.isMonitoring else { return }
            
            for (index, packet) in packets.enumerated() {
                let protocolType = protocols[index]
                self.analyzePacket(packet, protocolType: protocolType)
            }
            
            // Continue reading packets
            self.readPacketsFromTunnel(packetFlow: packetFlow)
        }
    }
    
    private func analyzePacket(_ packet: Data, protocolType: NSNumber) {
        // Parse the packet to extract domain information
        // This is a simplified implementation - in production you'd want more robust parsing
        
        // Check if this is a DNS packet (protocol 17 = UDP, port 53 = DNS)
        if protocolType.intValue == 17 {
            analyzeDNSPacket(packet)
        }
        
        // Check if this is an HTTPS packet (protocol 6 = TCP, port 443 = HTTPS)
        if protocolType.intValue == 6 {
            analyzeHTTPSPacket(packet)
        }
    }
    
    private func analyzeDNSPacket(_ packet: Data) {
        // DNS packets are typically UDP packets to port 53
        // Extract the domain name from DNS queries
        
        guard packet.count > 12 else { return } // Minimum DNS header size
        
        // Parse DNS header and extract query domain
        // This is a simplified DNS parser
        if let domain = extractDomainFromDNSPacket(packet) {
            checkDomainForLocationService(domain)
        }
    }
    
    private func analyzeHTTPSPacket(_ packet: Data) {
        // HTTPS packets contain TLS handshakes with SNI (Server Name Indication)
        // Extract the hostname from TLS SNI extension
        
        if let hostname = extractHostnameFromHTTPSPacket(packet) {
            checkDomainForLocationService(hostname)
        }
    }
    
    private func extractDomainFromDNSPacket(_ packet: Data) -> String? {
        // Simplified DNS packet parsing
        // In a real implementation, you'd parse the DNS header and query section
        
        guard packet.count > 12 else { return nil }
        
        // Skip DNS header (12 bytes)
        let queryData = packet.dropFirst(12)
        
        // Parse domain name from query section
        // This is a basic implementation - production code would be more robust
        var domain = ""
        var position = 0
        
        while position < queryData.count {
            let length = Int(queryData[queryData.startIndex + position])
            if length == 0 { break } // End of domain name
            
            position += 1
            if position + length <= queryData.count {
                let domainPart = queryData[position..<(position + length)]
                if let domainString = String(data: domainPart, encoding: .utf8) {
                    if !domain.isEmpty { domain += "." }
                    domain += domainString
                }
                position += length
            } else {
                break
            }
        }
        
        return domain.isEmpty ? nil : domain
    }
    
    private func extractHostnameFromHTTPSPacket(_ packet: Data) -> String? {
        // Simplified TLS SNI extraction
        // In a real implementation, you'd parse the TLS handshake and extract SNI
        
        // Look for TLS handshake (type 0x16) and SNI extension (0x0000)
        guard packet.count > 5 else { return nil }
        
        // Check if this is a TLS handshake
        if packet[0] == 0x16 { // TLS Handshake
            // Look for SNI extension in TLS extensions
            // This is a simplified search - production code would parse TLS properly
            if let sniRange = packet.range(of: Data([0x00, 0x00])) { // SNI extension type
                // Extract hostname from SNI extension
                // This is a basic implementation
                let sniData = packet[sniRange.upperBound...]
                if sniData.count > 2 {
                    let hostnameLength = Int(sniData[sniData.startIndex + 1])
                    if sniData.count > 2 + hostnameLength {
                        let hostnameData = sniData[2..<(2 + hostnameLength)]
                        return String(data: hostnameData, encoding: .utf8)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func checkDomainForLocationService(_ domain: String) {
        let lowercasedDomain = domain.lowercased()
        
        for (knownDomain, service) in locationDomains {
            if lowercasedDomain.contains(knownDomain.lowercased()) {
                logger.info("🔍 Location access detected: \(domain) (\(service))")
                recordDetection(domain: domain, service: service)
                break
            }
        }
    }
    
    private func recordDetection(domain: String, service: String) {
        let detection = [
            "timestamp": Date().timeIntervalSince1970,
            "domain": domain,
            "service": service
        ] as [String: Any]
        
        // Save detection to shared UserDefaults (App Group)
        let userDefaults = UserDefaults(suiteName: "group.com.phoneguardian.infiloc")
        var detections = userDefaults?.array(forKey: "tunnel_detections") as? [[String: Any]] ?? []
        detections.append(detection)
        
        // Keep only last 100 detections
        if detections.count > 100 {
            detections = Array(detections.suffix(100))
        }
        
        userDefaults?.set(detections, forKey: "tunnel_detections")
        userDefaults?.synchronize()
        
        // Send notification to main app
        sendDetectionNotification(domain: domain, service: service)
    }
    
    private func sendDetectionNotification(domain: String, service: String) {
        // Post a notification that the main app can listen for
        let notificationName = Notification.Name("InfiLocDetection")
        let userInfo: [String: Any] = [
            "domain": domain,
            "service": service,
            "timestamp": Date()
        ]
        
        NotificationCenter.default.post(
            name: notificationName,
            object: nil,
            userInfo: userInfo
        )
        
        logger.info("Detection notification sent: \(service) - \(domain)")
    }
}
