import SwiftUI

// Define ServiceRecord struct since it's not defined in DeviceWarrantyManager
struct ServiceRecord: Identifiable {
    let id = UUID()
    let serviceType: String
    let date: String
    let status: String
    let cost: String
}

struct DeviceWarrantyInfoView: View {
    @StateObject private var warrantyManager = DeviceWarrantyManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Warranty Status Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Warranty Status", icon: "checkmark.shield")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "shield.checkered", label: "Warranty Status", value: warrantyManager.getSupportStatusDescription(), iconColor: warrantyManager.getSupportStatusColor())
                        ModernInfoRow(icon: "calendar", label: "Purchase Date", value: warrantyManager.formatDate(warrantyManager.warrantyInfo.purchaseDate), iconColor: .blue)
                        ModernInfoRow(icon: "calendar.badge.clock", label: "Warranty Expiry", value: warrantyManager.formatDate(warrantyManager.warrantyInfo.expirationDate), iconColor: .orange)
                        ModernInfoRow(icon: "clock.arrow.circlepath", label: "Days Remaining", value: warrantyManager.getDaysRemainingDescription(warrantyManager.warrantyInfo.daysRemaining), iconColor: .green)
                    }
                }
                .modernCard()
                
                // Coverage Details Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Coverage Details", icon: "doc.text")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "iphone", label: "Hardware Coverage", value: warrantyManager.warrantyInfo.isActive ? "Covered" : "Not Covered", iconColor: warrantyManager.warrantyInfo.isActive ? .green : .red)
                        ModernInfoRow(icon: "wrench.and.screwdriver", label: "Technical Support", value: warrantyManager.appleCareInfo.isActive ? "Available" : "Not Available", iconColor: warrantyManager.appleCareInfo.isActive ? .green : .red)
                        ModernInfoRow(icon: "shippingbox", label: "Repair Coverage", value: warrantyManager.warrantyInfo.isActive ? "Covered" : "Not Covered", iconColor: warrantyManager.warrantyInfo.isActive ? .green : .red)
                        ModernInfoRow(icon: "arrow.triangle.2.circlepath", label: "Replacement Coverage", value: warrantyManager.appleCareInfo.isActive ? "Covered" : "Not Covered", iconColor: warrantyManager.appleCareInfo.isActive ? .green : .red)
                    }
                }
                .modernCard()
                
                // Device Information Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Device Information", icon: "info.circle")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "iphone", label: "Device Model", value: warrantyManager.warrantyInfo.modelIdentifier, iconColor: .blue)
                        ModernInfoRow(icon: "number", label: "Serial Number", value: warrantyManager.warrantyInfo.serialNumber, iconColor: .gray)
                        ModernInfoRow(icon: "building.2", label: "Country/Region", value: "United States", iconColor: .purple)
                        ModernInfoRow(icon: "tag", label: "Warranty Type", value: warrantyManager.getWarrantyTypeDescription(warrantyManager.warrantyInfo.warrantyType), iconColor: .orange)
                    }
                }
                .modernCard()
                
                // AppleCare Information Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "AppleCare Information", icon: "apple.logo")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "apple.logo", label: "AppleCare Plan", value: warrantyManager.getAppleCarePlanDescription(warrantyManager.appleCareInfo.planType), iconColor: .blue)
                        ModernInfoRow(icon: "number.circle", label: "Incidents Remaining", value: "\(warrantyManager.appleCareInfo.incidentsRemaining)", iconColor: .green)
                        ModernInfoRow(icon: "calendar.badge.clock", label: "AppleCare Expiry", value: warrantyManager.formatDate(warrantyManager.appleCareInfo.expirationDate), iconColor: .orange)
                        ModernInfoRow(icon: "clock.arrow.circlepath", label: "Days Remaining", value: warrantyManager.getDaysRemainingDescription(warrantyManager.appleCareInfo.daysRemaining), iconColor: .green)
                    }
                }
                .modernCard()
                
                // Service History Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Service History", icon: "clock.arrow.circlepath")
                    
                    Text("No service history available")
                        .foregroundColor(.secondary)
                        .padding()
                }
                .modernCard()
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await warrantyManager.checkWarrantyStatus()
                            }
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Check Warranty Status")
                            }
                        }
                        .modernButton(backgroundColor: .blue)
                        
                        Button(action: {
                            // Open Apple Support functionality
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("Contact Apple Support")
                            }
                        }
                        .modernButton(backgroundColor: .green)
                        
                        Button(action: {
                            // Schedule repair functionality
                        }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Schedule Repair")
                            }
                        }
                        .modernButton(backgroundColor: .orange)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Device Warranty")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await warrantyManager.checkWarrantyStatus()
            }
        }
    }
}

struct ServiceHistoryRow: View {
    let service: ServiceRecord
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wrench.and.screwdriver")
                .foregroundColor(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(service.serviceType)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(service.date) • \(service.status)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(service.cost)
                .font(.caption)
                .foregroundColor(service.cost == "Covered" ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
} 