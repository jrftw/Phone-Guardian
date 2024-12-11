import SwiftUI
import os

struct ToolsView: View {
    @EnvironmentObject var iapManager: IAPManager
    let onAdRequest: (AdFeatureUnlock) -> Void
    private let logger = Logger(subsystem: "com.phoneguardian.toolsview", category: "ToolsView")
    @State private var unlockedFeatures: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if iapManager.hasToolsSubscription {
                    featureCard(title: "Tools", description: "All Tools are unlocked.", features: toolsFeatures, unlocked: true)
                } else {
                    featureCard(title: "Tools",
                                description: "Unlock the Tools Add-on for just $2.99 and enjoy access to these powerful utilities:",
                                features: toolsFeatures,
                                unlocked: false)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .colorScheme(.dark)
    }

    private var toolsFeatures: [FeatureItem] {
        [
            FeatureItem(name: "Network Speed Test", icon: "speedometer"),
            FeatureItem(name: "Scanner (PDF, Docs, etc.)", icon: "doc.text.viewfinder"),
            FeatureItem(name: "Document Conversion", icon: "arrow.2.circlepath.doc.on.clipboard"),
            FeatureItem(name: "Private Storage for Files", icon: "lock.doc")
        ]
    }

    private func featureCard(title: String, description: String, features: [FeatureItem], unlocked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.white)

            ForEach(features, id: \.name) { feature in
                HStack {
                    Image(systemName: feature.icon)
                        .foregroundColor(.white)
                    Text(feature.name)
                        .foregroundColor(.white)
                    Spacer()
                    if unlocked || unlockedFeatures.contains(feature.name) {
                        switch feature.name {
                        case "Network Speed Test":
                            NavigationLink("Open", destination: NetworkSpeedTestView())
                                .foregroundColor(.blue)
                        case "Scanner (PDF, Docs, etc.)":
                            NavigationLink("Open", destination: ScannerView())
                                .foregroundColor(.blue)
                        case "Document Conversion":
                            NavigationLink("Open", destination: DocumentConversionView())
                                .foregroundColor(.blue)
                        case "Private Storage for Files":
                            NavigationLink("Open", destination: PrivateStorageView())
                                .foregroundColor(.blue)
                        default:
                            EmptyView()
                        }
                    } else {
                        // Check environment before showing "Watch Ad"
                        if !PGEnvironment.isSimulator && !PGEnvironment.isTestFlight {
                            Button(action: {
                                watchAdForFeature(feature.name)
                            }) {
                                Text("Watch Ad")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.orange)
                                    .cornerRadius(5)
                            }
                        } else {
                            // In simulator or TestFlight, no "Watch Ad" - just locked
                            Text("Locked")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }

            if !unlocked {
                Button(action: {
                    purchaseTools()
                }) {
                    Text("Purchase Tools for $2.99")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Button(action: {
                    restorePurchases()
                }) {
                    Text("Restore Purchases")
                        .foregroundColor(.blue)
                        .font(.body)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6).opacity(0.15))
        .cornerRadius(12)
    }

    private func watchAdForFeature(_ feature: String) {
        let unlockAction = AdFeatureUnlock(featureName: feature) { success in
            if success {
                unlockedFeatures.insert(feature)
            }
        }
        onAdRequest(unlockAction)
    }

    private func purchaseTools() {
        Task {
            await iapManager.purchaseTools()
        }
    }

    private func restorePurchases() {
        Task {
            await iapManager.restorePurchases()
        }
    }
}
