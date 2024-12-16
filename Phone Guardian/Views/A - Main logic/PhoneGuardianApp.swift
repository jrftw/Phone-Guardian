// PhoneGuardianApp.swift (Main Entry Point)

import SwiftUI
import os.log
import UserNotifications

@main
struct PhoneGuardianApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var iapManager = IAPManager()
    @StateObject private var moduleManager = ModuleManager()
    @State private var showTrackingExplanation: Bool

    private let logger = Logger(subsystem: "com.phoneguardian.app", category: "PhoneGuardianApp")

    init() {
        let hasSeenTrackingExplanation = UserDefaults.standard.bool(forKey: "HasSeenTrackingExplanation")
        let trackingAuthorized = UserDefaults.standard.object(forKey: "TrackingAuthorized") as? Bool

        if trackingAuthorized == nil {
            _showTrackingExplanation = State(initialValue: true)
        } else if trackingAuthorized == false && !hasSeenTrackingExplanation {
            _showTrackingExplanation = State(initialValue: true)
        } else {
            _showTrackingExplanation = State(initialValue: false)
        }
    }

    var body: some Scene {
        WindowGroup {
            if showTrackingExplanation {
                TrackingExplanationView(showTrackingPrompt: $showTrackingExplanation)
            } else {
                ContentView()
                    .environmentObject(iapManager)
                    .environmentObject(moduleManager)
                    .onAppear {
                        InterstitialAdHandler.shared.preloadAd()
                        requestAndScheduleInactivityNotification()
                    }
            }
        }
    }

    private func requestAndScheduleInactivityNotification() {
        AppNotificationManager.shared.requestNotificationAuthorization { granted in
            if granted {
                DispatchQueue.main.async {
                    AppNotificationManager.shared.cancelInactivityNotification()
                    let days = Int.random(in: 3...7)
                    AppNotificationManager.shared.scheduleInactivityNotification(in: days)
                }
            } else {
                self.logger.info("User did not grant notification permission.")
            }
        }
    }
}
