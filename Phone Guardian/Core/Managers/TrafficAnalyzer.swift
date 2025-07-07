import Foundation
import Network
import os.log

class TrafficAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    @Published var currentStatus = "Ready"
    
    private let logger = Logger(subsystem: "com.phoneguardian.infiloc", category: "TrafficAnalyzer")
    private var vpnManager: VPNManager
    
    // Known location service domains
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
    
    init(vpnManager: VPNManager) {
        self.vpnManager = vpnManager
    }
    
    // MARK: - Traffic Analysis
    func startAnalysis() {
        isAnalyzing = true
        currentStatus = "Starting VPN tunnel..."
        logger.info("Starting INFILOC traffic analysis")
        
        // Start the VPN tunnel which will handle real traffic analysis
        Task {
            await vpnManager.startVPN()
            
            await MainActor.run {
                if self.vpnManager.isVPNEnabled {
                    self.currentStatus = "Monitoring network traffic..."
                } else {
                    self.currentStatus = "Failed to start monitoring"
                    self.isAnalyzing = false
                }
            }
        }
    }
    
    func stopAnalysis() {
        isAnalyzing = false
        currentStatus = "Stopping analysis..."
        logger.info("Stopping INFILOC traffic analysis")
        
        Task {
            await vpnManager.stopVPN()
            
            await MainActor.run {
                self.currentStatus = "Analysis stopped"
            }
        }
    }
    
    // MARK: - Domain Detection
    func analyzeDomain(_ domain: String) -> Bool {
        let lowercasedDomain = domain.lowercased()
        
        for (knownDomain, service) in locationDomains {
            if lowercasedDomain.contains(knownDomain.lowercased()) {
                logger.info("Location service detected: \(domain) -> \(service)")
                vpnManager.recordDetection(domain: domain, service: service)
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Real-time Status Updates
    func updateStatus() {
        if vpnManager.isVPNEnabled {
            currentStatus = "Monitoring network traffic..."
        } else {
            currentStatus = "VPN tunnel not active"
        }
    }
    
    // MARK: - Domain List Management
    func getKnownDomains() -> [String: String] {
        return locationDomains
    }
    
    func addCustomDomain(_ domain: String, service: String) {
        // In a real implementation, this would save to persistent storage
        logger.info("Added custom domain: \(domain) -> \(service)")
    }
    
    func removeCustomDomain(_ domain: String) {
        // In a real implementation, this would remove from persistent storage
        logger.info("Removed custom domain: \(domain)")
    }
    
    // MARK: - Statistics
    func getDetectionStats() -> (total: Int, today: Int, thisWeek: Int) {
        let detections = vpnManager.loadDetections()
        let total = detections.count
        
        let calendar = Calendar.current
        let now = Date()
        
        let today = detections.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }.count
        
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let thisWeek = detections.filter { $0.timestamp >= weekAgo }.count
        
        return (total, today, thisWeek)
    }
    
    // MARK: - Load Combined Detections
    func loadAllDetections() -> [LocationDetection] {
        var allDetections = vpnManager.loadDetections()
        let tunnelDetections = vpnManager.loadTunnelDetections()
        
        // Combine and deduplicate detections
        allDetections.append(contentsOf: tunnelDetections)
        
        // Remove duplicates based on timestamp and domain
        let uniqueDetections = Array(Set(allDetections.map { "\($0.timestamp.timeIntervalSince1970)-\($0.domain)" }))
            .compactMap { key in
                allDetections.first { "\($0.timestamp.timeIntervalSince1970)-\($0.domain)" == key }
            }
        
        return uniqueDetections.sorted { $0.timestamp > $1.timestamp }
    }
} 