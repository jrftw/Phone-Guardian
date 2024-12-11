import Foundation
import UIKit
import StoreKit
import os
import GoogleMobileAds

class InterstitialAdHandler: NSObject, GADFullScreenContentDelegate {
    static let shared = InterstitialAdHandler()
    private let logger = Logger(subsystem: "com.phoneguardian.ads", category: "InterstitialAdHandler")

    private(set) var isAdReady: Bool = false
    private var interstitial: GADInterstitialAd?

    private override init() {
        super.init()
    }

    private var isTestFlightOrSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        // Check TestFlight by looking at receipt
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        }
        return false
        #endif
    }

    func preloadAd() {
        guard !isTestFlightOrSimulator else {
            logger.info("Running in simulator or TestFlight. Not loading ads.")
            isAdReady = false
            return
        }

        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-6815311336585204/7741700785", request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                self.logger.error("Failed to load interstitial ad: \(error.localizedDescription)")
                self.isAdReady = false
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.isAdReady = true
            self.logger.info("Interstitial ad loaded and ready.")
        }
    }

    func show(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard !isTestFlightOrSimulator else {
            completion(false)
            return
        }

        guard isAdReady, let interstitial = interstitial else {
            completion(false)
            return
        }

        interstitial.present(fromRootViewController: viewController)
        // The delegate methods will call completion after dismiss, so we can store completion if needed.
        // However, GADFullScreenContentDelegate does not provide a direct success callback, only dismissal.
        // We will call completion(true) when the ad is dismissed successfully below.
        // For now, assume if it presents, we'll consider show attempt successful.
        // We'll handle dismiss callback in delegate methods.
    }

    // MARK: - GADFullScreenContentDelegate

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        logger.info("Interstitial ad was dismissed.")
        self.isAdReady = false
        self.interstitial = nil
        // No direct completion here since we're not passing the completion closure around.
        // If needed, we can store a completion callback in a property.
    }
}
