// InterstitialAdHandler.swift

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
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
            return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        }
        return false
        #endif
    }

    func preloadAd() {
        guard !isTestFlightOrSimulator else {
            isAdReady = false
            return
        }
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6815311336585204/7741700785", request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if error != nil {
                self.isAdReady = false
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.isAdReady = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isAdReady = false
        interstitial = nil
    }
}
