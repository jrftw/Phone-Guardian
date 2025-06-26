// InterstitialAdHandler.swift

import Foundation
import GoogleMobileAds
import os
import UIKit

final class InterstitialAdHandler: NSObject, GADFullScreenContentDelegate {
    static let shared = InterstitialAdHandler()
    private let logger = Logger(subsystem: "com.phoneguardian.interstitial", category: "InterstitialAdHandler")
    private var interstitial: GADInterstitialAd?
    var isAdReady: Bool {
        return interstitial != nil
    }

    override init() {
        super.init()
        loadAd()
    }

    func preloadAd() {
        loadAd()
    }

    func loadAd() {
        let request = GADRequest()
        if PGEnvironment.isTestFlight || PGEnvironment.isSimulator {
            DispatchQueue.main.async {
                self.interstitial = nil
            }
            return
        }
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-6815311336585204/6456978932", request: request) { ad, error in
            if let error = error {
                self.logger.error("Failed to load interstitial ad: \(error.localizedDescription)")
                self.interstitial = nil
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
        }
    }

    func show(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let interstitial = interstitial else {
            completion(false)
            return
        }
        interstitial.present(fromRootViewController: viewController)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
        loadAd()
    }
}
