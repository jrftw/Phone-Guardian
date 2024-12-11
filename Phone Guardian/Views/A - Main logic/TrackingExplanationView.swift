//
//  TrackingExplanationView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/27/24.
//


import SwiftUI
import AppTrackingTransparency
import os.log

struct TrackingExplanationView: View {
    // MARK: - Properties
    @Binding var showTrackingPrompt: Bool

    // MARK: - Body
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

    // MARK: - Private Methods
    private func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    showTrackingPrompt = false
                    UserDefaults.standard.set(true, forKey: "HasSeenTrackingExplanation")

                    switch status {
                    case .authorized:
                        UserDefaults.standard.set(true, forKey: "TrackingAuthorized")
                        os_log("Tracking authorized.")
                    case .denied:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                        os_log("Tracking denied.")
                    case .restricted, .notDetermined:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                        os_log("Tracking restricted or not determined.")
                    @unknown default:
                        UserDefaults.standard.set(false, forKey: "TrackingAuthorized")
                        os_log("Unknown tracking status.")
                    }
                }
            }
        } else {
            showTrackingPrompt = false
            os_log("Tracking not available on this iOS version.")
        }
    }
}