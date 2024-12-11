//
//  BannerAdViewController.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/22/24.
//


import UIKit
import GoogleMobileAds

class BannerAdViewController: UIViewController {

    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a banner ad view
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-6815311336585204/7321160278" // My Banner Ad Unit ID
        bannerView.rootViewController = self
        bannerView.delegate = self
        view.addSubview(bannerView)

        // Load an ad
        bannerView.load(GADRequest())

        // Add layout constraints for banner
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension BannerAdViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner ad received.")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner ad failed to load: \(error.localizedDescription)")
    }
}
