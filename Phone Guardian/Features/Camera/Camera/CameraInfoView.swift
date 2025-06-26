import SwiftUI

struct CameraInfoView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Camera Information Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Camera Information", icon: "camera")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "camera.filters", label: "Telephoto Sensor", value: "Available", iconColor: .blue)
                        ModernInfoRow(icon: "rays", label: "LiDAR", value: "Available", iconColor: .green)
                        ModernInfoRow(icon: "camera", label: "Wide Sensor", value: "Available", iconColor: .orange)
                        ModernInfoRow(icon: "camera.aperture", label: "Ultra-Wide Sensor", value: "Available", iconColor: .purple)
                        ModernInfoRow(icon: "lightbulb", label: "Flashlight", value: "Available", iconColor: .yellow)
                    }
                }
                .modernCard()
                
                // More Info Button
                NavigationLink(destination: DetailedCameraInfoView()) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("More Camera Information")
                    }
                }
                .modernButton(backgroundColor: .blue)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
}

struct DetailedCameraInfoView: View {
    @EnvironmentObject var iapManager: IAPManager
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Camera Features Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Camera Features", icon: "camera")
                    
                    LazyVStack(spacing: 16) {
                        CameraFeatureCard(
                            title: "Telephoto Sensor",
                            description: "Allows capturing images with optical zoom, providing greater detail for distant subjects.",
                            icon: "camera.filters",
                            iconColor: .blue
                        )
                        
                        CameraFeatureCard(
                            title: "LiDAR",
                            description: "Used for depth sensing, enabling better AR experiences and low-light photography.",
                            icon: "rays",
                            iconColor: .green
                        )
                        
                        CameraFeatureCard(
                            title: "Wide Sensor",
                            description: "Standard camera sensor for capturing everyday photos and videos.",
                            icon: "camera",
                            iconColor: .orange
                        )
                        
                        CameraFeatureCard(
                            title: "Ultra-Wide Sensor",
                            description: "Captures a broader field of view, ideal for landscapes or group shots.",
                            icon: "camera.aperture",
                            iconColor: .purple
                        )
                        
                        CameraFeatureCard(
                            title: "Flashlight",
                            description: "Built-in torch used for illumination in low-light conditions.",
                            icon: "lightbulb",
                            iconColor: .yellow
                        )
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Camera Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CameraFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
    }
}
