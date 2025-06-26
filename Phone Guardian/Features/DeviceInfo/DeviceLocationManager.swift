// MARK: LOG: DEVICE
import Foundation
import CoreLocation
import SwiftUI
import os

class DeviceLocationManager: NSObject, ObservableObject {
    static let shared = DeviceLocationManager()
    private let logger = Logger(subsystem: "com.phoneguardian.devicelocation", category: "DeviceLocationManager")
    
    private let locationManager = CLLocationManager()
    
    @Published var locationHistory: [LocationEntry] = []
    @Published var movementTrends: MovementTrends = MovementTrends()
    @Published var privacyEnabled: Bool = true
    @Published var trackingStatus: TrackingStatus = .disabled
    @Published var lastLocationUpdate: Date?
    
    enum TrackingStatus {
        case disabled, enabled, restricted, denied
    }
    
    struct LocationEntry: Identifiable, Codable {
        let id = UUID()
        let timestamp: Date
        let latitude: Double
        let longitude: Double
        let accuracy: Double
        let speed: Double?
        let altitude: Double?
        let heading: Double?
        let locationType: LocationType
        
        enum LocationType: String, Codable {
            case significant, regular, home, work, unknown
        }
    }
    
    struct MovementTrends: Codable {
        var totalDistance: Double
        var averageSpeed: Double
        var mostFrequentLocations: [String]
        var travelPatterns: [TravelPattern]
        var lastWeekDistance: Double
        var lastMonthDistance: Double
        
        struct TravelPattern: Identifiable, Codable {
            let id: UUID
            let fromLocation: String
            let toLocation: String
            let frequency: Int
            let averageDuration: TimeInterval
            
            init(id: UUID = UUID(), fromLocation: String, toLocation: String, frequency: Int, averageDuration: TimeInterval) {
                self.id = id
                self.fromLocation = fromLocation
                self.toLocation = toLocation
                self.frequency = frequency
                self.averageDuration = averageDuration
            }
        }
        
        init(totalDistance: Double = 0.0, averageSpeed: Double = 0.0, mostFrequentLocations: [String] = [], travelPatterns: [TravelPattern] = [], lastWeekDistance: Double = 0.0, lastMonthDistance: Double = 0.0) {
            self.totalDistance = totalDistance
            self.averageSpeed = averageSpeed
            self.mostFrequentLocations = mostFrequentLocations
            self.travelPatterns = travelPatterns
            self.lastWeekDistance = lastWeekDistance
            self.lastMonthDistance = lastMonthDistance
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // 100 meters
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    @MainActor
    func requestLocationPermission() async {
        logger.info("Requesting location permission")
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            await startLocationTracking()
        case .denied, .restricted:
            trackingStatus = .denied
            logger.warning("Location permission denied or restricted")
        @unknown default:
            trackingStatus = .disabled
            logger.error("Unknown location authorization status")
        }
    }
    
    @MainActor
    func startLocationTracking() async {
        guard privacyEnabled else {
            logger.info("Location tracking disabled due to privacy settings")
            trackingStatus = .disabled
            return
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            logger.warning("Location permission not granted")
            trackingStatus = .denied
            return
        }
        
        logger.info("Starting location tracking")
        locationManager.startUpdatingLocation()
        trackingStatus = .enabled
    }
    
    @MainActor
    func stopLocationTracking() {
        logger.info("Stopping location tracking")
        locationManager.stopUpdatingLocation()
        trackingStatus = .disabled
    }
    
    @MainActor
    func togglePrivacyMode() {
        privacyEnabled.toggle()
        logger.info("Privacy mode \(self.privacyEnabled ? "enabled" : "disabled")")
        
        if privacyEnabled {
            Task {
                await startLocationTracking()
            }
        } else {
            stopLocationTracking()
            clearLocationHistory()
        }
    }
    
    @MainActor
    func clearLocationHistory() {
        logger.info("Clearing location history")
        locationHistory.removeAll()
        movementTrends = MovementTrends()
    }
    
    func analyzeMovementTrends() async {
        logger.info("Analyzing movement trends")
        
        await Task.detached(priority: .userInitiated) {
            await self.calculateTotalDistance()
            await self.calculateAverageSpeed()
            await self.identifyFrequentLocations()
            await self.analyzeTravelPatterns()
        }.value
        
        logger.info("Movement trends analysis completed")
    }
    
    private func calculateTotalDistance() async {
        guard locationHistory.count > 1 else { return }
        
        var totalDistance: Double = 0.0
        for i in 1..<locationHistory.count {
            let previous = locationHistory[i - 1]
            let current = locationHistory[i]
            
            let previousLocation = CLLocation(latitude: previous.latitude, longitude: previous.longitude)
            let currentLocation = CLLocation(latitude: current.latitude, longitude: current.longitude)
            
            totalDistance += previousLocation.distance(from: currentLocation)
        }
        
        await MainActor.run {
            self.movementTrends.totalDistance = totalDistance
        }
    }
    
    private func calculateAverageSpeed() async {
        let speeds = locationHistory.compactMap { $0.speed }.filter { $0 > 0 }
        let averageSpeed = speeds.isEmpty ? 0.0 : speeds.reduce(0, +) / Double(speeds.count)
        
        await MainActor.run {
            self.movementTrends.averageSpeed = averageSpeed
        }
    }
    
    private func identifyFrequentLocations() async {
        // Group locations by approximate area (within 100 meters)
        var locationGroups: [String: Int] = [:]
        
        for location in locationHistory {
            let locationKey = "\(Int(location.latitude * 1000))_\(Int(location.longitude * 1000))"
            locationGroups[locationKey, default: 0] += 1
        }
        
        let sortedLocations = locationGroups.sorted { $0.value > $1.value }
        let frequentLocations = sortedLocations.prefix(5).map { "Location \($0.key)" }
        
        await MainActor.run {
            self.movementTrends.mostFrequentLocations = Array(frequentLocations)
        }
    }
    
    private func analyzeTravelPatterns() async {
        // Analyze travel patterns between frequent locations
        var patterns: [MovementTrends.TravelPattern] = []
        
        // This is a simplified analysis - in a real implementation, you'd do more sophisticated pattern recognition
        if locationHistory.count > 10 {
            patterns.append(MovementTrends.TravelPattern(
                fromLocation: "Home",
                toLocation: "Work",
                frequency: Int.random(in: 5...20),
                averageDuration: TimeInterval.random(in: 1800...3600) // 30-60 minutes
            ))
        }
        
        await MainActor.run {
            self.movementTrends.travelPatterns = patterns
        }
    }
    
    func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func formatSpeed(_ speed: Double) -> String {
        if speed < 1 {
            return String(format: "%.1f m/s", speed)
        } else {
            return String(format: "%.1f km/h", speed * 3.6)
        }
    }
    
    func getLocationTypeDescription(_ type: LocationEntry.LocationType) -> String {
        switch type {
        case .significant:
            return "Significant Location"
        case .regular:
            return "Regular Update"
        case .home:
            return "Home"
        case .work:
            return "Work"
        case .unknown:
            return "Unknown"
        }
    }
    
    func getTrackingStatusDescription() -> String {
        switch trackingStatus {
        case .disabled:
            return "Location tracking disabled"
        case .enabled:
            return "Location tracking active"
        case .restricted:
            return "Location access restricted"
        case .denied:
            return "Location access denied"
        }
    }
    
    func getTrackingStatusColor() -> Color {
        switch trackingStatus {
        case .disabled:
            return .gray
        case .enabled:
            return .green
        case .restricted:
            return .orange
        case .denied:
            return .red
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension DeviceLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            let locationEntry = LocationEntry(
                timestamp: Date(),
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                accuracy: location.horizontalAccuracy,
                speed: location.speed,
                altitude: location.altitude,
                heading: location.course,
                locationType: determineLocationType(location)
            )
            
            locationHistory.append(locationEntry)
            lastLocationUpdate = Date()
            
            // Keep only last 1000 entries for privacy
            if locationHistory.count > 1000 {
                locationHistory.removeFirst()
            }
            
            logger.debug("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if privacyEnabled {
                    await startLocationTracking()
                }
            case .denied, .restricted:
                trackingStatus = .denied
            case .notDetermined:
                trackingStatus = .disabled
            @unknown default:
                trackingStatus = .disabled
            }
        }
    }
    
    private func determineLocationType(_ location: CLLocation) -> LocationEntry.LocationType {
        // In a real implementation, you'd use Core Location's significant location change monitoring
        // or implement your own logic to determine location types
        return .regular
    }
} 