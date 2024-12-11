import SwiftUI
import GoogleMobileAds

struct SupportUsSectionView: View {
    @Binding var adWatchCounter: Int
    @State private var isAdLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var isAdReady: Bool = true // Simulating ad availability

    var body: some View {
        Section(header: Text("Support Us")) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Enjoying the app? Support us by viewing ads, donating, or leaving a rating!")
                    .font(.body)

                if shouldShowSupportButtonOnly {
                    supportButton()
                } else if isAdReady {
                    AdBannerView()
                        .frame(height: 50)

                    Button(action: {
                        watchAd()
                    }) {
                        if isAdLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(10)
                        } else {
                            Text("Watch Video Ad")
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isAdLoading)
                    .buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Ad Not Ready"),
                            message: Text("The ad is not ready to be displayed. Please try again later."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                } else {
                    supportButton()
                }

                VStack(spacing: 8) {
                    Text("Rate Phone Guardian")
                        .font(.headline)

                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.vertical)

                    Button(action: openAppStoreRatingPage) {
                        Text("Rate Now")
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                            .font(.headline)
                    }
                }

                Text("Ads Watched: \(adWatchCounter)")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helper Methods
    private func watchAd() {
        isAdLoading = true
        if let rootViewController = UIApplication.getTopViewController() {
            InterstitialAdHandler.shared.show(from: rootViewController) { success in
                DispatchQueue.main.async {
                    isAdLoading = false
                    if success {
                        adWatchCounter += 1
                    } else {
                        showAlert = true
                    }
                }
            }
        } else {
            isAdLoading = false
            showAlert = true
        }
    }

    private func supportButton() -> some View {
        Button(action: {
            if let url = URL(string: "https://infinitumlive.com/support-our-development") {
                UIApplication.shared.open(url)
            }
        }) {
            Text("Support Us")
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
                .font(.headline)
        }
    }

    private func openAppStoreRatingPage() {
        let appID = "6738286864"
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)?action=write-review") else {
            print("Failed to construct App Store URL.")
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    print("Failed to open App Store URL.")
                }
            }
        } else {
            print("App Store URL cannot be opened.")
        }
    }

    private var shouldShowSupportButtonOnly: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || PGEnvironment.isSimulator || PGEnvironment.isTestFlight
    }
}

// MARK: - UIApplication Extension
extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopViewController(base: selected)
            }
        }

        if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }

        return base
    }
}
