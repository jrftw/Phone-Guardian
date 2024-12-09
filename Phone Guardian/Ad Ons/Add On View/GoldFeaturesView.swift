import SwiftUI
import os

struct GoldFeaturesView: View {
    @EnvironmentObject var iapManager: IAPManager
    let onAdRequest: (AdFeatureUnlock) -> Void
    private let logger = Logger(subsystem: "com.phoneguardian.goldfeatures", category: "GoldFeaturesView")
    @State private var unlockedFeatures: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if iapManager.hasGoldSubscription {
                    featureCard(title: "Gold", description: "All Gold features are unlocked!", features: goldFeatures, unlocked: true)
                } else {
                    featureCard(title: "Gold",
                                description: "Unlock Gold for just $2.99 and enjoy premium features:",
                                features: goldFeatures,
                                unlocked: false)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .colorScheme(.dark)
    }

    private var goldFeatures: [FeatureItem] {
        [
            FeatureItem(name: "Ad-Free Experience", icon: "nosign"),
            FeatureItem(name: "Test Kit", icon: "checkmark.seal"),
            FeatureItem(name: "Export Reports to PDF", icon: "doc.text"),
            FeatureItem(name: "Notification Kit", icon: "bell.badge"),
            FeatureItem(name: "Clean Duplicates", icon: "trash.circle")
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

                    if feature.name == "Ad-Free Experience" {
                        // If unlocked or user has Gold (unlocked anyway)
                        if unlocked {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(5)
                        } else {
                            // Locked ad-free experience, no watch ad in any environment
                            Text("Locked")
                                .foregroundColor(.gray)
                        }
                    } else {
                        if unlocked || unlockedFeatures.contains(feature.name) {
                            switch feature.name {
                            case "Test Kit":
                                NavigationLink("Open", destination: TestKitView())
                                    .foregroundColor(.blue)
                            case "Export Reports to PDF":
                                NavigationLink("Open", destination: ReportsView())
                                    .foregroundColor(.blue)
                            case "Notification Kit":
                                NavigationLink("Open", destination: NotificationKitView())
                                    .foregroundColor(.blue)
                            case "Clean Duplicates":
                                NavigationLink("Open", destination: DuplicateScanView())
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
                                // In simulator or TestFlight, just show locked
                                Text("Locked")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }

            if !unlocked {
                Button(action: {
                    purchaseGold()
                }) {
                    Text("Purchase Gold for $2.99")
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

    private func purchaseGold() {
        Task {
            await iapManager.purchaseGold()
        }
    }

    private func restorePurchases() {
        Task {
            await iapManager.restorePurchases()
        }
    }
}
