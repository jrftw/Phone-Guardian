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
        setTunnelNetworkSettings(settings) { error in
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
        // Start reading packets from the tunnel
        readPackets { [weak self] packets, protocols in
            guard let self = self, self.isMonitoring else { return }
            
            for packet in packets {
                self.analyzePacket(packet)
            }
            
            // Continue reading packets
            self.startPacketProcessing()
        }
    }
    
    private func analyzePacket(_ packet: Data) {
        // This is a simplified packet analysis
        // In a real implementation, you would parse the packet headers and extract domain information
        
        // For demonstration, we'll simulate packet analysis
        // In practice, you would:
        // 1. Parse IP headers
        // 2. Parse TCP/UDP headers
        // 3. Extract DNS queries or HTTPS hostnames
        // 4. Check against our domain list
        
        // Simulate finding a domain (this would come from actual packet parsing)
        let simulatedDomains = ["gsp-ssl.ls.apple.com", "api.life360.com", "maps.googleapis.com"]
        
        for domain in simulatedDomains {
            if let service = locationDomains[domain] {
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
        if let data = try? JSONSerialization.data(withJSONObject: detection) {
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
