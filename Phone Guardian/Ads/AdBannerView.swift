// AdBannerView.swift

import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-6815311336585204/7321160278"
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                bannerView.rootViewController = rootViewController
                bannerView.load(GADRequest())
            }
        }
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
