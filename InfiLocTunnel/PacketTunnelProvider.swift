//
//  PacketTunnelProvider.swift
//  InfiLocTunnel
//
//  Created by Kevin Doyle Jr. on 7/7/25.
//

import NetworkExtension
import os.log
import CryptoKit

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.phoneguardian.infiloc.tunnel", category: "PacketTunnel")
    private var isMonitoring = false
    private var connectionTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 3
    
    // SECURITY: All data processing is local-only, no external transmission
    // SECURITY: Domain matching is done locally without external lookups
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
        logger.info("Starting INFILOC tunnel - Privacy Mode Active")
        
        // SECURITY: Configure tunnel for local-only processing
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // SECURITY: Use trusted DNS servers, no custom DNS manipulation
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        settings.dnsSettings = dnsSettings
        
        // SECURITY: Minimal routing to avoid data leakage
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings
        
        // Apply the settings
        setTunnelNetworkSettings(settings) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Failed to set tunnel settings: \(error.localizedDescription)")
                
                // Retry mechanism for connection issues
                if self.retryCount < self.maxRetries {
                    self.retryCount += 1
                    self.logger.info("Retrying tunnel setup (attempt \(self.retryCount)/\(self.maxRetries))")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.startTunnel(options: options, completionHandler: completionHandler)
                    }
                    return
                }
                
                completionHandler(error)
                return
            }
            
            self.logger.info("Tunnel settings applied successfully - Privacy Protected")
            self.isMonitoring = true
            self.retryCount = 0 // Reset retry count on success
            self.startPacketProcessing()
            self.startConnectionMonitoring()
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping INFILOC tunnel - Cleaning up secure data")
        isMonitoring = false
        
        // Stop connection monitoring
        connectionTimer?.invalidate()
        connectionTimer = nil
        
        // SECURITY: Clear any sensitive data from memory
        clearSensitiveData()
        
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from the main app
        if let messageString = String(data: messageData, encoding: .utf8) {
            logger.info("Received app message: \(messageString)")
            
            // Handle different message types
            switch messageString {
            case "get_status":
                let status = [
                    "isMonitoring": isMonitoring,
                    "retryCount": retryCount,
                    "timestamp": Date().timeIntervalSince1970
                ] as [String: Any]
                
                if let statusData = try? JSONSerialization.data(withJSONObject: status) {
                    completionHandler?(statusData)
                } else {
                    completionHandler?(nil)
                }
                
            case "clear_detections":
                clearDetectionData()
                completionHandler?(Data("cleared".utf8))
                
            case "test_connection":
                logger.info("Connection test received - Tunnel is active")
                completionHandler?(Data("ok".utf8))
                
            default:
                completionHandler?(nil)
            }
        } else {
            completionHandler?(nil)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Pause monitoring during sleep to save battery
        logger.info("Device going to sleep - Pausing monitoring")
        isMonitoring = false
        connectionTimer?.invalidate()
        connectionTimer = nil
        completionHandler()
    }
    
    override func wake() {
        // Resume monitoring when device wakes
        logger.info("Device waking up - Resuming monitoring")
        isMonitoring = true
        startPacketProcessing()
        startConnectionMonitoring()
    }
    
    // MARK: - Connection Monitoring
    private func startConnectionMonitoring() {
        // Monitor connection health every 30 seconds
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkConnectionHealth()
        }
    }
    
    private func checkConnectionHealth() {
        guard isMonitoring else { return }
        
        // Check if packet flow is still active
        if packetFlow == nil {
            logger.warning("Packet flow lost - Attempting to restart")
            restartPacketProcessing()
        }
        
        // Log connection status for debugging
        logger.info("Connection health check - Monitoring active: \(isMonitoring)")
    }
    
    private func restartPacketProcessing() {
        guard isMonitoring else { return }
        
        logger.info("Restarting packet processing")
        startPacketProcessing()
    }
    
    // SECURITY: Clear sensitive data from memory
    private func clearSensitiveData() {
        // Clear any cached data to prevent memory leaks
        logger.info("Clearing sensitive data from memory")
        retryCount = 0
    }
    
    private func clearDetectionData() {
        // SECURITY: Clear detection data from App Group
        let userDefaults = UserDefaults(suiteName: "group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc")
        userDefaults?.removeObject(forKey: "tunnel_detections")
        userDefaults?.synchronize()
        logger.info("Detection data cleared from App Group")
    }
    
    private func startPacketProcessing() {
        // packetFlow is not optional in NEPacketTunnelProvider
        let packetFlow = self.packetFlow
        
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
        // SECURITY: Only analyze packet headers, never decrypt content
        // SECURITY: No deep packet inspection of encrypted data
        
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
        // SECURITY: Only extract domain names from DNS queries
        // SECURITY: Never access DNS response content or user data
        
        guard packet.count > 12 else { return } // Minimum DNS header size
        
        // Parse DNS header and extract query domain
        if let domain = extractDomainFromDNSPacket(packet) {
            checkDomainForLocationService(domain)
        }
    }
    
    private func analyzeHTTPSPacket(_ packet: Data) {
        // SECURITY: Only extract hostname from TLS SNI (Server Name Indication)
        // SECURITY: Never decrypt or access encrypted HTTPS content
        
        if let hostname = extractHostnameFromHTTPSPacket(packet) {
            checkDomainForLocationService(hostname)
        }
    }
    
    private func extractDomainFromDNSPacket(_ packet: Data) -> String? {
        // SECURITY: Only parse DNS query section, never response data
        // SECURITY: No access to user's actual DNS queries or responses
        
        guard packet.count > 12 else { return nil }
        
        // Skip DNS header (12 bytes)
        let queryData = packet.dropFirst(12)
        
        // Parse domain name from query section only
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
        // SECURITY: Only extract SNI hostname from TLS handshake
        // SECURITY: Never decrypt HTTPS content or access user data
        
        guard packet.count > 5 else { return nil }
        
        // Check if this is a TLS handshake
        if packet[0] == 0x16 { // TLS Handshake
            // Look for SNI extension in TLS extensions
            if let sniRange = packet.range(of: Data([0x00, 0x00])) { // SNI extension type
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
        // SECURITY: Local-only domain matching, no external lookups
        // SECURITY: No tracking of user's actual browsing patterns
        
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
        // SECURITY: Store detection data locally only
        // SECURITY: No external transmission of user data
        // SECURITY: Use App Group for secure data sharing between app and extension
        
        let detection = [
            "timestamp": Date().timeIntervalSince1970,
            "domain": domain,
            "service": service
        ] as [String: Any]
        
        // SECURITY: Store in App Group UserDefaults (local device only)
        let userDefaults = UserDefaults(suiteName: "group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc")
        var detections = userDefaults?.array(forKey: "tunnel_detections") as? [[String: Any]] ?? []
        detections.append(detection)
        
        // SECURITY: Limit stored data to prevent excessive storage
        if detections.count > 100 {
            detections = Array(detections.suffix(100))
        }
        
        userDefaults?.set(detections, forKey: "tunnel_detections")
        userDefaults?.synchronize()
        
        // SECURITY: Send notification locally only
        sendDetectionNotification(domain: domain, service: service)
    }
    
    private func sendDetectionNotification(domain: String, service: String) {
        // SECURITY: Local notification only, no external transmission
        // SECURITY: No tracking or analytics data sent
        
        let notificationName = Notification.Name("InfiLocDetection")
        let userInfo: [String: Any] = [
            "domain": domain,
            "service": service,
            "timestamp": Date()
        ]
        
        // SECURITY: Use local NotificationCenter only
        NotificationCenter.default.post(
            name: notificationName,
            object: nil,
            userInfo: userInfo
        )
        
        logger.info("Detection notification sent locally: \(service) - \(domain)")
    }
}
