import SwiftUI
import UIKit
import StoreKit

struct RatingPromptView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Enjoying Phone Guardian?")
                .font(.title)
                .multilineTextAlignment(.center)

            Text("Consider giving us a rating on the App Store to help us.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }
            }
            .padding(.vertical)

            HStack(spacing: 20) {
                Button(action: {
                    openAppStorePage()
                    markAppAsRated()
                    isPresented = false
                }) {
                    Text("Rate Now")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    isPresented = false
                }) {
                    Text("Later")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }

    private func openAppStorePage() {
        let appStoreURL = "itms-apps://apps.apple.com/us/app/phone-guardian-protect/id6738286864?action=write-review"
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }

    private func markAppAsRated() {
        UserDefaults.standard.set(true, forKey: "hasRatedApp")
    }
}
