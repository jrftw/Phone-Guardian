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
        currentStatus = "Monitoring network traffic..."
        logger.info("Starting INFILOC traffic analysis")
        
        // In a real implementation, this would be handled by the NEPacketTunnelProvider
        // For now, we'll simulate detection for demonstration purposes
        simulateTrafficMonitoring()
    }
    
    func stopAnalysis() {
        isAnalyzing = false
        currentStatus = "Analysis stopped"
        logger.info("Stopped INFILOC traffic analysis")
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
    
    // MARK: - Simulated Monitoring (for demonstration)
    private func simulateTrafficMonitoring() {
        // This is a simulation for demonstration purposes
        // In a real implementation, this would be handled by the NEPacketTunnelProvider
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Simulate some detections after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.simulateDetection(domain: "gsp-ssl.ls.apple.com", service: "Find My iPhone")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
                self.simulateDetection(domain: "api.life360.com", service: "Life360")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
                self.simulateDetection(domain: "maps.googleapis.com", service: "Google Maps")
            }
        }
    }
    
    private func simulateDetection(domain: String, service: String) {
        guard isAnalyzing else { return }
        
        DispatchQueue.main.async {
            self.currentStatus = "🔍 Detected: \(service)"
        }
        
        vpnManager.recordDetection(domain: domain, service: service)
        
        // Reset status after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.isAnalyzing {
                self.currentStatus = "Monitoring network traffic..."
            }
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
} 