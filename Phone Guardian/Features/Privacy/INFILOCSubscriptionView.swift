import SwiftUI
import StoreKit

struct INFILOCSubscriptionView: View {
    @StateObject private var subscriptionManager = INFILOCSubscriptionManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingPurchaseAlert = false
    @State private var showingRestoreAlert = false
    @State private var showingLegalDisclaimer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("INFILOC Privacy Monitor")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Advanced Location Access Detection")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 12) {
                            FeatureRow(icon: "location.slash", title: "Real-time Monitoring", description: "Detect location access attempts instantly")
                            FeatureRow(icon: "bell", title: "Smart Notifications", description: "Get alerted when apps access your location")
                            FeatureRow(icon: "lock.shield", title: "100% Private", description: "All processing done locally on your device")
                            FeatureRow(icon: "chart.bar", title: "Detailed Analytics", description: "Track and analyze location access patterns")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Subscription Options
                    VStack(spacing: 16) {
                        Text("Choose Your Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if subscriptionManager.isLoading {
                            ProgressView("Loading subscription options...")
                                .padding()
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                                    SubscriptionCard(
                                        product: product,
                                        isSelected: selectedProduct?.id == product.id,
                                        action: { selectedProduct = product }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Purchase Button
                    if let selectedProduct = selectedProduct {
                        VStack(spacing: 12) {
                            Button(action: purchaseSubscription) {
                                HStack {
                                    if subscriptionManager.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "lock.open")
                                    }
                                    Text("Subscribe to INFILOC")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(subscriptionManager.isLoading)
                            
                            Text("\(selectedProduct.formattedPrice) per \(selectedProduct.subscriptionPeriod)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Legal Disclaimers
                    VStack(spacing: 16) {
                        Button(action: { showingLegalDisclaimer = true }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Important Legal Information")
                                    .foregroundColor(.orange)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Detection Accuracy Disclaimer")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            
                            Text("INFILOC location detection is not 100% accurate and may not catch all location access attempts. Detection depends on network traffic patterns and may be affected by encryption, VPN usage, or other network configurations.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Additional Information
                    VStack(spacing: 12) {
                        Button(action: restorePurchases) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Restore Purchases")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Button(action: subscriptionManager.openSubscriptionManagement) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Manage Subscription")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("INFILOC Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Purchase Error", isPresented: .constant(subscriptionManager.errorMessage != nil)) {
                Button("OK") {
                    subscriptionManager.errorMessage = nil
                }
            } message: {
                if let errorMessage = subscriptionManager.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
                Button("Restore") {
                    Task {
                        await restorePurchases()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will restore any previous INFILOC subscriptions you may have purchased.")
            }
            .sheet(isPresented: $showingLegalDisclaimer) {
                LegalDisclaimerView()
            }
        }
    }
    
    // MARK: - Actions
    private func purchaseSubscription() {
        guard let selectedProduct = selectedProduct else { return }
        
        Task {
            let success = await subscriptionManager.purchase(selectedProduct)
            if success {
                dismiss()
            }
        }
    }
    
    private func restorePurchases() {
        showingRestoreAlert = true
    }
    
    private func restorePurchases() async {
        let success = await subscriptionManager.restorePurchases()
        if success {
            dismiss()
        }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SubscriptionCard: View {
    let product: Product
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(product.subscriptionType)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(product.formattedPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("per \(product.subscriptionPeriod)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if product.subscriptionType == "Yearly" {
                    Text("Save 40%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegalDisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Detection Accuracy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detection Accuracy Disclaimer")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("INFILOC location detection is not 100% accurate and may not catch all location access attempts. The effectiveness of detection depends on several factors:")
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Network traffic patterns and encryption methods")
                            BulletPoint("VPN usage and network configurations")
                            BulletPoint("App-specific implementation of location services")
                            BulletPoint("System-level privacy protections")
                            BulletPoint("Network infrastructure and routing")
                        }
                        
                        Text("While INFILOC uses advanced packet analysis techniques, it cannot guarantee detection of all location access attempts due to the complex nature of modern network communications.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Legal Compliance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Legal Compliance")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("INFILOC is designed for personal privacy monitoring only and complies with applicable laws and regulations:")
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("All processing is performed locally on your device")
                            BulletPoint("No data is transmitted to external servers")
                            BulletPoint("No user data is collected or stored by developers")
                            BulletPoint("Compliant with Apple's App Store guidelines")
                            BulletPoint("Respects user privacy and data protection laws")
                        }
                    }
                    
                    // Limitations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Service Limitations")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("INFILOC has the following limitations:")
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Cannot decrypt encrypted traffic content")
                            BulletPoint("May not detect location access through certain VPNs")
                            BulletPoint("Detection accuracy varies by network environment")
                            BulletPoint("Requires VPN permissions to function")
                            BulletPoint("May impact battery life and network performance")
                        }
                    }
                    
                    // User Responsibility
                    VStack(alignment: .leading, spacing: 12) {
                        Text("User Responsibility")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("By using INFILOC, you acknowledge that:")
                            .font(.body)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint("Detection results are for informational purposes only")
                            BulletPoint("You are responsible for your own privacy decisions")
                            BulletPoint("The service is provided 'as is' without warranties")
                            BulletPoint("You will not use INFILOC for illegal purposes")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Legal Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundColor(.blue)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

#Preview {
    INFILOCSubscriptionView()
} 