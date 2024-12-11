import SwiftUI
import GoogleMobileAds
import os

struct VideoAdView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdDismissed: (Bool) -> Void
    @State private var isAdLoaded = false
    @State private var rewardedAd: GADRewardedAd?
    private let logger = Logger(subsystem: "com.phoneguardian.videoAd", category: "VideoAdView")

    private var isTestFlightOrSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        }
        return false
        #endif
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if !isTestFlightOrSimulator {
                if isAdLoaded {
                    Text("Ad Loaded. Presenting...")
                        .foregroundColor(.white)
                        .onAppear {
                            showRewardedAd()
                        }
                } else {
                    ProgressView("Loading Ad...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            } else {
                // No ads in test flight or simulator
                Text("No Ads in test environment.")
                    .foregroundColor(.white)
                    .onAppear {
                        DispatchQueue.main.async {
                            onAdDismissed(true)
                            dismiss()
                        }
                    }
            }
        }
        .onAppear {
            if !isTestFlightOrSimulator {
                loadRewardedAd()
            }
        }
    }

    private func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-6815311336585204/REWARDED_AD_UNIT_ID",
                           request: request) { ad, error in
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
            // User earned reward callback
            // For simplicity, we treat ad shown successfully as onAdDismissed(true)
            onAdDismissed(true)
            dismiss()
        }
    }
}
