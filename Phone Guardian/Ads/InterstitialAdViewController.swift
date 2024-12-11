import UIKit
import GoogleMobileAds

class InterstitialAdViewController: UIViewController {
    var interstitial: GADInterstitialAd?
    var onAdDismissed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterstitialAd()
    }

    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: "ca-app-pub-6815311336585204/7741700785", // Replace with your Ad Unit ID
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                self?.onAdDismissed?()
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            self?.showAd()
        }
    }

    func showAd() {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad not ready")
            onAdDismissed?()
        }
    }
}

extension InterstitialAdViewController: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad was dismissed.")
        onAdDismissed?()
        dismiss(animated: true)
    }
}
