// InterstitialAdHandler.swift

import Foundation
import os

#if os(iOS)
import UIKit
import GoogleMobileAds
#endif

class InterstitialAdHandler: NSObject {
    static let shared = InterstitialAdHandler()
    private let logger = Logger(subsystem: "com.phoneguardian.ads", category: "InterstitialAdHandler")
    #if os(iOS)
    private var interstitial: GADInterstitialAd?
    #endif
    private(set) var isAdReady: Bool = false

    private override init() {
        super.init()
    }

    func preloadAd() {
        #if os(iOS)
        guard !PGEnvironment.isSimulator && !PGEnvironment.isTestFlight else {
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
        #else
        isAdReady = false
        #endif
    }

    func show(from viewController: AnyObject, completion: @escaping (Bool) -> Void) {
        #if os(iOS)
        guard !PGEnvironment.isSimulator && !PGEnvironment.isTestFlight else {
            completion(false)
            return
        }
        guard isAdReady, let interstitial = interstitial, let vc = viewController as? UIViewController else {
            completion(false)
            return
        }
        interstitial.present(fromRootViewController: vc)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(true)
        }
        #else
        completion(false)
        #endif
    }
}

#if os(iOS)
extension InterstitialAdHandler: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isAdReady = false
        interstitial = nil
    }
}
#endif
