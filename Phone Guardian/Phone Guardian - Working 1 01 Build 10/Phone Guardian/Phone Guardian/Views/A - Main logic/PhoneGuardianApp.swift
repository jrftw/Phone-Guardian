import SwiftUI
import os
import GoogleMobileAds

@main
struct PhoneGuardianApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    @AppStorage("enableLogging") private var enableLogging: Bool = false

    private let logger = Logger(subsystem: "com.phoneguardian.app", category: "AppLifecycle")

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    if enableLogging {
                        logger.info("PhoneGuardianApp launched.")
                    }
                }
                .onDisappear {
                    if enableLogging {
                        logger.info("PhoneGuardianApp terminated.")
                    }
                }
        }
    }
}
