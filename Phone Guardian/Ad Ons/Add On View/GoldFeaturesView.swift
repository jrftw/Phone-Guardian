// GoldFeaturesView.swift

import SwiftUI
import os

private struct FeatureToUnlock: Identifiable {
    let id = UUID()
    let name: String
}

struct GoldFeaturesView: View {
    @EnvironmentObject var iapManager: IAPManager
    let onAdRequest: (AdFeatureUnlock) -> Void
    @State private var unlockedFeatures: Set<String> = []
    @State private var currentFeatureToUnlock: FeatureToUnlock?
    private let logger = Logger(subsystem: "com.phoneguardian.goldfeatures", category: "GoldFeaturesView")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if iapManager.hasGoldSubscription {
                        featureCard(title: "Gold",
                                    description: "All Gold features are unlocked!",
                                    features: goldFeatures,
                                    unlocked: true)
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
            .fullScreenCover(item: $currentFeatureToUnlock) { feature in
                VideoAdView { success in
                    if success {
                        unlockedFeatures.insert(feature.name)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            logger.info("GoldFeaturesView appeared.")
            InterstitialAdHandler.shared.preloadAd()
        }
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
                        if unlocked {
                            Text("Enabled")
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(5)
                        } else {
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
                            if !PGEnvironment.isSimulator && !PGEnvironment.isTestFlight && InterstitialAdHandler.shared.isAdReady {
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
                                Text("Locked")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            if !unlocked {
                Button(action: {
                    Task {
                        await iapManager.purchaseGold()
                    }
                }) {
                    Text("Purchase Gold for $2.99")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Button(action: {
                    Task {
                        await iapManager.restorePurchases()
                    }
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
        currentFeatureToUnlock = FeatureToUnlock(name: feature)
    }
}
