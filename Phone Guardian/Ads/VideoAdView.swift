// VideoAdView.swift

import SwiftUI
import os
#if os(iOS)
import GoogleMobileAds
import UIKit
#endif

struct VideoAdView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdDismissed: (Bool) -> Void
    #if os(iOS)
    @State private var isAdLoaded = false
    @State private var rewardedAd: GADRewardedAd?
    private let logger = Logger(subsystem: "com.phoneguardian.videoAd", category: "VideoAdView")
    #endif

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            #if os(iOS)
            if isTestFlightOrSimulator {
                Text("No Ads in test environment.")
                    .foregroundColor(.white)
                    .onAppear {
                        DispatchQueue.main.async {
                            onAdDismissed(true)
                            dismiss()
                        }
                    }
            } else {
                if isAdLoaded {
                    Text("Presenting Ad...")
                        .foregroundColor(.white)
                        .onAppear {
                            showRewardedAd()
                        }
                } else {
                    ProgressView("Loading Ad...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            #else
            Text("Ads not available on this platform.")
                .foregroundColor(.white)
                .onAppear {
                    onAdDismissed(true)
                    dismiss()
                }
            #endif
        }
        .onAppear {
            #if os(iOS)
            if !isTestFlightOrSimulator {
                loadRewardedAd()
            } else {
                DispatchQueue.main.async {
                    onAdDismissed(true)
                    dismiss()
                }
            }
            #endif
        }
    }

    #if os(iOS)
    private var isTestFlightOrSimulator: Bool {
        if PGEnvironment.isSimulator { return true }
        if PGEnvironment.isTestFlight { return true }
        return false
    }

    private func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-6815311336585204/5224354917", request: request) { ad, error in
            if let error = error {
                logger.error("Failed to load rewarded ad: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    onAdDismissed(false)
                    dismiss()
                }
                return
            }
            rewardedAd = ad
            isAdLoaded = true
        }
    }

    private func showRewardedAd() {
        guard let rewardedAd = rewardedAd,
              let rootViewController = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
            onAdDismissed(false)
            dismiss()
            return
        }
        rewardedAd.present(fromRootViewController: rootViewController) {
            onAdDismissed(true)
            dismiss()
        }
    }
    #endif
}
