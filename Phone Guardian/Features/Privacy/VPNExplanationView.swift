import SwiftUI

struct VPNExplanationView: View {
    @Binding var showingPermission: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // What is INFILOC
                    whatIsSection
                    
                    // How it works
                    howItWorksSection
                    
                    // Privacy & Security
                    privacySection
                    
                    // What it detects
                    detectionSection
                    
                    // User Control
                    controlSection
                    
                    // Legal Disclaimers
                    legalDisclaimersSection
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("About INFILOC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("INFILOC Privacy Monitor")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Passive Location Access Detection")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - What is INFILOC
    private var whatIsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What is INFILOC?")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("INFILOC is a privacy monitoring tool that passively detects when apps, websites, or services attempt to access your location without your explicit permission.")
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: "eye.slash")
                    .foregroundColor(.green)
                Text("Works in the background")
                    .font(.subheadline)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                Text("Monitors network traffic")
                    .font(.subheadline)
            }
            
            HStack(spacing: 12) {
                Image(systemName: "location.circle")
                    .foregroundColor(.red)
                Text("Detects location requests")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - How it works
    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How does it work?")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text("1")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(.blue))
                    
                    Text("Creates a local VPN tunnel")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Text("2")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(.blue))
                    
                    Text("Intercepts network packets")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Text("3")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(.blue))
                    
                    Text("Analyzes for location services")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Text("4")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(.blue))
                    
                    Text("Alerts you of detection")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Privacy & Security
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy & Security")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("All processing happens locally on your device")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("NO data is ever sent to external servers")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("NO data shared with developers or advertisers")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("VPN only processes headers, never content")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("You control all data and notifications")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("100% compliant with Apple Privacy Guidelines")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - What it detects
    private var detectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What does it detect?")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                    Text("Google Maps location requests")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                    Text("Apple Location Services")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                    Text("Weather app location access")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                    Text("Social media location tracking")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.red)
                    Text("Ad tracking location requests")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - User Control
    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You're in control")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "toggle.on")
                        .foregroundColor(.blue)
                    Text("Start/stop monitoring anytime")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                    Text("Enable/disable notifications")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "trash")
                        .foregroundColor(.blue)
                    Text("Clear detection history")
                        .font(.subheadline)
                }
                
                HStack(spacing: 12) {
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                    Text("Customize monitoring settings")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Legal Disclaimers
    private var legalDisclaimersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Important Legal Information")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("⚠️ Detection Accuracy Disclaimer")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("INFILOC location detection is not 100% accurate and may not catch all location access attempts. Detection effectiveness depends on network traffic patterns, encryption methods, VPN usage, and other network configurations.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("While INFILOC uses advanced packet analysis techniques, it cannot guarantee detection of all location access attempts due to the complex nature of modern network communications.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Service Limitations:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Cannot decrypt encrypted traffic content")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• May not detect location access through certain VPNs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• Detection accuracy varies by network environment")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("• Results are for informational purposes only")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Mark that user has seen the explanation
                UserDefaults.standard.set(true, forKey: "infiloc_first_launch_seen")
                dismiss()
                showingPermission = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Enable INFILOC Monitoring")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            Button(action: { 
                // Mark that user has seen the explanation
                UserDefaults.standard.set(true, forKey: "infiloc_first_launch_seen")
                dismiss() 
            }) {
                Text("Learn More Later")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    VPNExplanationView(showingPermission: .constant(false))
} 