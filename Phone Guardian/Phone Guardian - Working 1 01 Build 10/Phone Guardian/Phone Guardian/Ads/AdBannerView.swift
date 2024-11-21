import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Replace with your Ad Unit ID
        
        // Access rootViewController using UIWindowScene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
            bannerView.load(GADRequest())
        } else {
            print("Unable to access rootViewController.")
        }

        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
