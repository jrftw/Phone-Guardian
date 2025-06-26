import SwiftUI
import CoreLocation

struct DeviceLocationInfoView: View {
    @StateObject private var locationManager = DeviceLocationManager.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Location Status Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Location Status", icon: "location")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "location.fill", label: "Tracking Status", value: locationManager.getTrackingStatusDescription(), iconColor: locationManager.getTrackingStatusColor())
                        ModernInfoRow(icon: "eye.slash", label: "Privacy Mode", value: locationManager.privacyEnabled ? "Enabled" : "Disabled", iconColor: locationManager.privacyEnabled ? .green : .red)
                        ModernInfoRow(icon: "clock", label: "Last Update", value: formatLastUpdate(), iconColor: .blue)
                    }
                }
                .modernCard()
                
                // Movement Trends Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Movement Trends", icon: "figure.walk")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "ruler", label: "Total Distance", value: locationManager.formatDistance(locationManager.movementTrends.totalDistance), iconColor: .blue)
                        ModernInfoRow(icon: "speedometer", label: "Average Speed", value: locationManager.formatSpeed(locationManager.movementTrends.averageSpeed), iconColor: .green)
                        ModernInfoRow(icon: "calendar", label: "Last Week Distance", value: locationManager.formatDistance(locationManager.movementTrends.lastWeekDistance), iconColor: .orange)
                        ModernInfoRow(icon: "calendar.badge.clock", label: "Last Month Distance", value: locationManager.formatDistance(locationManager.movementTrends.lastMonthDistance), iconColor: .purple)
                    }
                }
                .modernCard()
                
                // Location History Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Location History", icon: "map")
                    
                    if locationManager.locationHistory.isEmpty {
                        Text("No location history available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(locationManager.locationHistory.suffix(5)) { entry in
                                LocationHistoryRow(entry: entry)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await locationManager.requestLocationPermission()
                            }
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Request Location Permission")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            locationManager.togglePrivacyMode()
                        }) {
                            HStack {
                                Image(systemName: locationManager.privacyEnabled ? "eye.slash" : "eye")
                                Text(locationManager.privacyEnabled ? "Disable Privacy Mode" : "Enable Privacy Mode")
                            }
                        }
                        .modernButton(backgroundColor: locationManager.privacyEnabled ? .orange : .green)
                        
                        Button(action: {
                            locationManager.clearLocationHistory()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Location History")
                            }
                        }
                        .modernButton(backgroundColor: .red)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Device Location")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await locationManager.analyzeMovementTrends()
            }
        }
        .alert("Location Permission Required", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            Text("Please enable location permissions in Settings to use this feature.")
        }
    }
    
    private func formatLastUpdate() -> String {
        guard let lastUpdate = locationManager.lastLocationUpdate else {
            return "Never"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: lastUpdate)
    }
}

struct LocationHistoryRow: View {
    let entry: DeviceLocationManager.LocationEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle")
                .foregroundColor(.red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(format: "%.4f", entry.latitude)), \(String(format: "%.4f", entry.longitude))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(entry.locationType.rawValue.capitalized) • \(formatDate(entry.timestamp))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let speed = entry.speed, speed > 0 {
                Text(String(format: "%.1f m/s", speed))
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
} 