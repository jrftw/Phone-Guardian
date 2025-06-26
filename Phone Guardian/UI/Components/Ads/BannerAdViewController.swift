// BannerAdViewController.swift

import UIKit
import GoogleMobileAds

class BannerAdViewController: UIViewController {
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-6815311336585204/7321160278"
        bannerView.rootViewController = self
        bannerView.delegate = self
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        bannerView.load(GADRequest())
    }
}

extension BannerAdViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {}
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {}
}
