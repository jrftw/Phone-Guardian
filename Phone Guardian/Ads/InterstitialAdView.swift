// InterstitialAdView.swift

import SwiftUI
import UIKit

struct InterstitialAdView: UIViewControllerRepresentable {
    var onAdDismissed: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        if InterstitialAdHandler.shared.isAdReady {
            InterstitialAdHandler.shared.show(from: viewController) { _ in }
        } else {
            DispatchQueue.main.async {
                onAdDismissed()
            }
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
