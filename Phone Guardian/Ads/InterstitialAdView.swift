import SwiftUI

struct InterstitialAdView: UIViewControllerRepresentable {
    var onAdDismissed: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        // Immediately try to show the ad from here if isAdReady
        if InterstitialAdHandler.shared.isAdReady {
            InterstitialAdHandler.shared.show(from: viewController) { success in
                // If success or fail doesn't matter; the delegate of InterstitialAdHandler handles dismissal
            }
        } else {
            // No ad ready, dismiss immediately
            DispatchQueue.main.async {
                onAdDismissed()
            }
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
