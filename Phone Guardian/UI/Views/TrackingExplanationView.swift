// TrackingExplanationView.swift

import SwiftUI
import AppTrackingTransparency
import os.log

struct TrackingExplanationView: View {
    @Binding var showTrackingPrompt: Bool

    var body: some View {
        VStack {
            Text("We Value Your Privacy")
                .font(.headline)
                .padding()

            Text("Allowing tracking helps us provide personalized ads and improve your experience.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()

            Button("Continue") {
                requestTrackingAuthorization()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    showTrackingPrompt = false
                    UserDefaults.standard.set(true, forKey: "HasSeenTrackingExplanation")
                    switch status {
                    case .authorized:
                        UserDefaults.standard.set(true, forKey: "TrackingAuthorized")
                    case .denied:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                    case .restricted, .notDetermined:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                    @unknown default:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                    }
                }
            }
        } else {
            showTrackingPrompt = false
        }
    }
}
