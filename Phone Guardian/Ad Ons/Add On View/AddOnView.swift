// AddOnsView.swift

import SwiftUI
import os

struct AddOnsView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var selection: String = "Tools"
    @State private var currentAdFeature: AdFeatureUnlock? = nil
    private let logger = Logger(subsystem: "com.phoneguardian.addons", category: "AddOnsView")

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Picker("Add-Ons", selection: $selection) {
                    Text("Tools").tag("Tools")
                    Text("Gold").tag("Gold")
                    Text("Remove Ads").tag("Remove Ads")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(Color.black)
                .colorScheme(.dark)

                if selection == "Tools" {
                    ToolsView(onAdRequest: { feature in
                        showAdForFeature(feature)
                    })
                    .environmentObject(iapManager)
                } else if selection == "Gold" {
                    GoldFeaturesView(onAdRequest: { feature in
                        showAdForFeature(feature)
                    })
                    .environmentObject(iapManager)
                } else if selection == "Remove Ads" {
                    removeAdsCard
                }
            }
        }
        .onChange(of: selection) { _ in
            currentAdFeature = nil
        }
        .fullScreenCover(item: $currentAdFeature) { feature in
            VideoAdView(onAdDismissed: { success in
                if success {
                    feature.completion(true)
                } else {
                    feature.completion(false)
                }
                currentAdFeature = nil
            })
        }
    }

    private var removeAdsCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Remove Ads")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)

                Text("Purchase the Remove Ads add-on for just $0.99 to remove all ads permanently from the app.* Do not purchase if you purchased gold")
                    .font(.subheadline)
                    .foregroundColor(.white)

                HStack {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.white)
                    Text("Ads")
                        .foregroundColor(.white)
                    Spacer()

                    if iapManager.hasRemoveAds {
                        Text("Enabled")
                            .foregroundColor(.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(5)
                    } else {
                        Button(action: {
                            Task {
                                await iapManager.purchaseRemoveAds()
                            }
                        }) {
                            Text("Purchase for $0.99")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }

                if !iapManager.hasRemoveAds {
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
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .colorScheme(.dark)
    }

    private func showAdForFeature(_ feature: AdFeatureUnlock) {
        guard !iapManager.hasRemoveAds else {
            feature.completion(false)
            return
        }
        guard InterstitialAdHandler.shared.isAdReady else {
            logger.info("Ad not ready, cannot show ad for feature: \(feature.featureName)")
            feature.completion(false)
            return
        }
        currentAdFeature = feature
    }
}
