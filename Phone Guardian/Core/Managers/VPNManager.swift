import Foundation
import NetworkExtension
import UserNotifications
import os.log

class VPNManager: ObservableObject {
    @Published var isVPNEnabled = false
    @Published var isMonitoring = false
    @Published var lastDetectionTime: Date?
    @Published var detectionCount = 0
    @Published var connectionStatus: NEVPNStatus = .invalid
    @Published var lastError: String?
    
    private let logger = Logger(subsystem: "com.phoneguardian.infiloc", category: "VPNManager")
    private var manager: NETunnelProviderManager?
    private var statusTimer: Timer?
    
    // SECURITY: Use App Group for secure data sharing between app and extension
    private let appGroupUserDefaults = UserDefaults(suiteName: "group.Infinitum-Imagery-LLC.Phone-Guardian.infiloc")
    
    init() {
        loadVPNStatus()
        setupNotificationListener()
        requestNotificationPermissions()
        startStatusMonitoring()
    }
    
    deinit {
        statusTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - VPN Configuration
    func setupVPN() async {
        logger.info("Setting up INFILOC VPN configuration - Privacy Mode")
        
        // SECURITY: Create VPN configuration for local-only processing
        let manager = NETunnelProviderManager()
        let config = NETunnelProviderProtocol()
        
        // SECURITY: Use localhost as server to ensure no external data transmission
        config.serverAddress = "127.0.0.1"
        config.providerBundleIdentifier = "Infinitum-Imagery-LLC.Phone-Guardian.InfiLocTunnel"
        config.disconnectOnSleep = false
        
        // Add custom configuration for better reliability
        config.providerConfiguration = [
            "enableLogging": true,
            "privacyMode": true,
            "maxRetries": 3
        ]
        
        manager.protocolConfiguration = config
        manager.isEnabled = true
        manager.localizedDescription = "INFILOC Privacy Monitor"
        
        do {
            try await manager.saveToPreferences()
            self.manager = manager
            logger.info("VPN configuration saved successfully - Privacy Protected")
        } catch {
            logger.error("Failed to save VPN configuration: \(error.localizedDescription)")
            await MainActor.run {
                self.lastError = "Failed to setup VPN: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Start/Stop VPN
    func startVPN() async {
        // Check subscription status before starting VPN
        let subscriptionManager = INFILOCSubscriptionManager()
        subscriptionManager.updateSubscriptionStatus()
        
        guard subscriptionManager.isSubscribed else {
            logger.error("VPN start blocked - No active INFILOC subscription")
            await MainActor.run {
                self.lastError = "INFILOC subscription required"
            }
            return
        }
        
        guard let manager = manager else {
            await setupVPN()
            return
        }
        
        do {
            try await manager.loadFromPreferences()
            try await manager.connection.startVPNTunnel()
            await MainActor.run {
                self.isVPNEnabled = true
                self.isMonitoring = true
                self.lastError = nil
            }
            logger.info("INFILOC VPN started successfully - Privacy Active")
        } catch {
            logger.error("Failed to start VPN: \(error.localizedDescription)")
            await MainActor.run {
                self.lastError = "Failed to start VPN: \(error.localizedDescription)"
            }
        }
    }
    
    func stopVPN() async {
        guard let manager = manager else { return }
        
        manager.connection.stopVPNTunnel()
        await MainActor.run {
            self.isVPNEnabled = false
            self.isMonitoring = false
            self.lastError = nil
        }
        logger.info("INFILOC VPN stopped - Privacy Cleanup Complete")
    }
    
    // MARK: - Status Management
    private func loadVPNStatus() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Failed to load VPN managers: \(error.localizedDescription)")
                return
            }
            
            if let manager = managers?.first {
                self.manager = manager
                DispatchQueue.main.async {
                    self.connectionStatus = manager.connection.status
                    self.isVPNEnabled = manager.connection.status == .connected
                    self.isMonitoring = manager.isEnabled
                }
            }
        }
    }
    
    private func startStatusMonitoring() {
        // Monitor VPN status every 10 seconds
        statusTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.updateVPNStatus()
        }
    }
    
    private func updateVPNStatus() {
        guard let manager = manager else { return }
        
        let newStatus = manager.connection.status
        if newStatus != connectionStatus {
            DispatchQueue.main.async {
                self.connectionStatus = newStatus
                self.isVPNEnabled = newStatus == .connected
                
                // Handle status changes
                switch newStatus {
                case .connected:
                    self.logger.info("VPN connected successfully")
                    self.lastError = nil
                case .disconnected:
                    self.logger.info("VPN disconnected")
                case .connecting:
                    self.logger.info("VPN connecting...")
                case .disconnecting:
                    self.logger.info("VPN disconnecting...")
                case .reasserting:
                    self.logger.info("VPN reasserting connection...")
                case .invalid:
                    self.logger.warning("VPN status invalid")
                    self.lastError = "VPN configuration invalid"
                @unknown default:
                    self.logger.warning("Unknown VPN status: \(newStatus.rawValue)")
                }
            }
        }
    }
    
    // MARK: - Tunnel Communication
    func getTunnelStatus() async -> [String: Any]? {
        guard let manager = manager,
              manager.connection.status == .connected,
              let session = manager.connection as? NETunnelProviderSession else {
            return nil
        }
        
        do {
            let response = try await session.sendProviderMessage(Data("get_status".utf8))
            if let responseData = response,
               let statusDict = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                return statusDict
            }
        } catch {
            logger.error("Failed to get tunnel status: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func clearTunnelDetections() async {
        guard let manager = manager,
              manager.connection.status == .connected,
              let session = manager.connection as? NETunnelProviderSession else {
            return
        }
        
        do {
            _ = try await session.sendProviderMessage(Data("clear_detections".utf8))
            logger.info("Tunnel detections cleared")
        } catch {
            logger.error("Failed to clear tunnel detections: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Notification Setup
    private func requestNotificationPermissions() {
        // SECURITY: Request minimal notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.logger.info("Notification permissions granted - Privacy Mode")
            } else {
                self.logger.error("Notification permissions denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func setupNotificationListener() {
        // SECURITY: Listen for local notifications only, no external data
        NotificationCenter.default.addObserver(
            forName: Notification.Name("InfiLocDetection"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let domain = userInfo["domain"] as? String,
                  let service = userInfo["service"] as? String else {
                return
            }
            
            self.handleDetection(domain: domain, service: service)
        }
    }
    
    private func handleDetection(domain: String, service: String) {
        DispatchQueue.main.async {
            self.lastDetectionTime = Date()
            self.detectionCount += 1
            
            // SECURITY: Save detection locally only
            self.saveDetection(domain: domain, service: service)
            
            // SECURITY: Show notification only if user has enabled it
            if UserDefaults.standard.bool(forKey: "infiloc_notifications") {
                self.showDetectionNotification(domain: domain, service: service)
            }
        }
        
        logger.info("Location access detected locally: \(domain) (\(service))")
    }
    
    private func showDetectionNotification(domain: String, service: String) {
        // SECURITY: Local notification only, no external transmission
        let content = UNMutableNotificationContent()
        content.title = "🔍 Location Access Detected"
        content.body = "\(service) attempted to access your location"
        content.sound = .default
        
        // SECURITY: No tracking identifiers in notifications
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.logger.error("Failed to show notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Detection Handling
    func recordDetection(domain: String, service: String) {
        DispatchQueue.main.async {
            self.lastDetectionTime = Date()
            self.detectionCount += 1
            
            // SECURITY: Save detection locally only
            self.saveDetection(domain: domain, service: service)
        }
        
        logger.info("Location access detected locally: \(domain) (\(service))")
    }
    
    private func saveDetection(domain: String, service: String) {
        // SECURITY: Store detection data locally only
        let detection = LocationDetection(
            timestamp: Date(),
            domain: domain,
            service: service
        )
        
        var detections = loadDetections()
        detections.append(detection)
        
        // SECURITY: Limit stored data to prevent excessive storage
        if detections.count > 100 {
            detections = Array(detections.suffix(100))
        }
        
        // SECURITY: Store in local UserDefaults only
        if let data = try? JSONEncoder().encode(detections) {
            UserDefaults.standard.set(data, forKey: "infiloc_detections")
        }
    }
    
    func loadDetections() -> [LocationDetection] {
        // SECURITY: Load from local storage only
        guard let data = UserDefaults.standard.data(forKey: "infiloc_detections"),
              let detections = try? JSONDecoder().decode([LocationDetection].self, from: data) else {
            return []
        }
        return detections
    }
    
    func clearDetections() {
        // SECURITY: Clear all local detection data
        UserDefaults.standard.removeObject(forKey: "infiloc_detections")
        detectionCount = 0
        lastDetectionTime = nil
        logger.info("All detection data cleared - Privacy Reset")
    }
    
    // MARK: - Load Detections from Tunnel Extension
    func loadTunnelDetections() -> [LocationDetection] {
        // SECURITY: Load from App Group (local device only)
        guard let tunnelDetections = appGroupUserDefaults?.array(forKey: "tunnel_detections") as? [[String: Any]] else {
            return []
        }
        
        return tunnelDetections.compactMap { detectionDict in
            guard let timestamp = detectionDict["timestamp"] as? TimeInterval,
                  let domain = detectionDict["domain"] as? String,
                  let service = detectionDict["service"] as? String else {
                return nil
            }
            
            return LocationDetection(
                timestamp: Date(timeIntervalSince1970: timestamp),
                domain: domain,
                service: service
            )
        }
    }
    
    // MARK: - Debug and Testing Utilities
    func testTunnelConnection() async -> Bool {
        guard let manager = manager,
              let session = manager.connection as? NETunnelProviderSession else {
            logger.error("No VPN manager available for testing")
            return false
        }
        
        do {
            let response = try await session.sendProviderMessage(Data("test_connection".utf8))
            if let responseData = response,
               let responseString = String(data: responseData, encoding: .utf8) {
                logger.info("Tunnel test response: \(responseString)")
                return responseString == "ok"
            }
        } catch {
            logger.error("Tunnel connection test failed: \(error.localizedDescription)")
        }
        
        return false
    }
    
    func getDebugInfo() -> [String: Any] {
        var debugInfo: [String: Any] = [:]
        
        // VPN Status
        debugInfo["vpn_enabled"] = isVPNEnabled
        debugInfo["is_monitoring"] = isMonitoring
        debugInfo["connection_status"] = connectionStatus.rawValue
        debugInfo["last_error"] = lastError
        
        // Detection Stats
        debugInfo["detection_count"] = detectionCount
        debugInfo["last_detection_time"] = lastDetectionTime?.timeIntervalSince1970
        
        // App Group Status
        debugInfo["app_group_available"] = appGroupUserDefaults != nil
        debugInfo["tunnel_detections_count"] = loadTunnelDetections().count
        
        // Manager Status
        if let manager = manager {
            debugInfo["manager_loaded"] = true
            debugInfo["manager_enabled"] = manager.isEnabled
            debugInfo["connection_status_raw"] = manager.connection.status.rawValue
        } else {
            debugInfo["manager_loaded"] = false
        }
        
        return debugInfo
    }
    
    func exportDebugLog() -> String {
        let debugInfo = getDebugInfo()
        let detections = loadDetections()
        let tunnelDetections = loadTunnelDetections()
        
        var log = "=== INFILOC Debug Log ===\n"
        log += "Timestamp: \(Date())\n\n"
        
        // Debug Info
        log += "--- Debug Information ---\n"
        for (key, value) in debugInfo {
            log += "\(key): \(value)\n"
        }
        log += "\n"
        
        // Local Detections
        log += "--- Local Detections (\(detections.count)) ---\n"
        for detection in detections {
            log += "\(detection.timestamp): \(detection.service) - \(detection.domain)\n"
        }
        log += "\n"
        
        // Tunnel Detections
        log += "--- Tunnel Detections (\(tunnelDetections.count)) ---\n"
        for detection in tunnelDetections {
            log += "\(detection.timestamp): \(detection.service) - \(detection.domain)\n"
        }
        
        return log
    }
    
    func simulateDetection() {
        // SECURITY: Only for testing purposes
        logger.info("Simulating location detection for testing")
        recordDetection(domain: "test.example.com", service: "Test Service")
    }
}

// MARK: - Location Detection Model
struct LocationDetection: Codable, Identifiable {
    var id: UUID
    let timestamp: Date
    let domain: String
    let service: String
    
    init(id: UUID = UUID(), timestamp: Date, domain: String, service: String) {
        self.id = id
        self.timestamp = timestamp
        self.domain = domain
        self.service = service
    }
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, domain, service
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
} 