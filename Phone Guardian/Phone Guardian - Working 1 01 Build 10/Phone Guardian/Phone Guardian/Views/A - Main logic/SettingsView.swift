import SwiftUI
import StoreKit
import os

struct SettingsView: View {
    @StateObject private var iapManager = IAPManager.shared
    @State private var updateFrequency: Double = 2
    @State private var enableLogging: Bool = false
    @State private var adWatchCounter: Int = 0
    @State private var modules: [Module] = [
        Module(name: "Device Info", view: AnyView(DeviceInfoView())),
        Module(name: "Battery Info", view: AnyView(BatteryInfoView())),
        Module(name: "CPU Usage", view: AnyView(CPUInfoView())),
        Module(name: "RAM Info", view: AnyView(RAMInfoView())),
        Module(name: "Storage Info", view: AnyView(StorageInfoView())),
        Module(name: "Network Info", view: AnyView(NetworkInfoView())),
        Module(name: "Sensor Info", view: AnyView(SensorInfoView())),
        Module(name: "Display Info", view: AnyView(DisplayInfoView())),
        Module(name: "Camera Info", view: AnyView(CameraInfoView()))
    ]
    @State private var activeModules = Array(repeating: true, count: 9)
    @AppStorage("appTheme") private var appTheme: String = "system"

    private let logger = Logger(subsystem: "com.phoneguardian.settings", category: "SettingsView")

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                List {
                    // Ad Banner
                    if !iapManager.hasGoldSubscription {
                        AdBannerView()
                            .frame(height: 50)
                    }

                    // Gold Section
                    Section(header: Text("Gold")) {
                        if iapManager.hasGoldSubscription {
                            Text("Gold Features Unlocked")
                                .font(.headline)
                                .foregroundColor(.green)
                            NavigationLink("Gold Features") {
                                GoldFeaturesView()
                            }
                            NavigationLink("Notification Kit") {
                                NotificationsView()
                            }
                        } else {
                            HStack {
                                Text("Gold")
                                Spacer()
                                Text("$2.99")
                                    .font(.headline)
                                Button(action: {
                                    Task {
                                        await iapManager.purchaseGold()
                                    }
                                }) {
                                    Text("Purchase")
                                        .foregroundColor(.blue)
                                }
                            }
                            Text("Unlock all features:")
                                .font(.subheadline)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("• Ad-free experience")
                                Text("• Advanced Virus Scanner")
                                Text("• Priority Support")
                                Text("• Test Kit - Test your device's hardware and sensors")
                                Text("• Export data to PDF")
                                Text("• Clean duplicates")
                                Text("• Deep Clean RAM Memory")
                                Text("• Notification Kit")
                            }
                            .font(.footnote)
                            Button(action: {
                                Task {
                                    await iapManager.restorePurchases()
                                }
                            }) {
                                Text("Restore Purchases")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // General Section
                    Section(header: Text("General")) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Update Frequency")
                                Spacer()
                                Text("\(Int(updateFrequency))s")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Slider(value: $updateFrequency, in: 2...60, step: 1)
                        }
                        Toggle("Clean RAM on Startup", isOn: .constant(true)) // Placeholder for actual state
                        HStack {
                            Text("Clean RAM Memory")
                            Spacer()
                            Button(action: {
                                performCleanRAM()
                            }) {
                                Text("Run")
                                    .foregroundColor(.blue)
                            }
                        }
                        HStack {
                            Text("Deep Clean RAM Memory")
                            Spacer()
                            if iapManager.hasGoldSubscription {
                                Button(action: {
                                    performDeepCleanRAM()
                                }) {
                                    Text("Run")
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Button(action: {
                                    Task {
                                        await iapManager.purchaseGold()
                                    }
                                }) {
                                    Text("Unlock with Gold")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }

                    // Appearance Section
                    Section(header: Text("Appearance")) {
                        Picker("App Theme", selection: $appTheme) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: appTheme) { newValue in
                            applyTheme(newValue)
                        }
                    }

                    // Support Section
                    Section(header: Text("Support Us")) {
                        if !iapManager.hasGoldSubscription {
                            AdBannerView()
                                .frame(height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text("Enjoying the app? Support us by viewing ads!")
                            Button(action: watchAd) {
                                Text("Watch Ad")
                                    .foregroundColor(.blue)
                            }
                        }
                        Text("Ads Watched: \(adWatchCounter)")
                    }

                    // Other Section
                    Section(header: Text("Other")) {
                        Link("Send Feedback", destination: URL(string: "mailto:kdoyle@infinitumimagery.com")!)
                        Link("Website", destination: URL(string: "https://infinitumlive.com/apps")!)
                        Link("Follow Developer", destination: URL(string: "https://www.tiktok.com/@jrftw")!)
                        NavigationLink("Changelog") {
                            ChangelogView()
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.85) // Adjust to allow space for the footer

                // Fixed Footer
                VStack {
                    Divider()
                    Text("Made in Pittsburgh, PA, USA 🇺🇸")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("Version 1.01 Build (10) © 2024 Infinitum Imagery LLC")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text("Made by @JrFTW All rights reserved.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(height: geometry.size.height * 0.15) // Allocate remaining height for footer
                .background(Color(UIColor.systemGray6))
            }
        }
        .navigationTitle("Settings")
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            Task {
                await iapManager.restorePurchases()
            }
        }
    }

    // MARK: - Apply Theme
    func applyTheme(_ theme: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        for window in windowScene.windows {
            switch theme {
            case "light":
                window.overrideUserInterfaceStyle = .light
            case "dark":
                window.overrideUserInterfaceStyle = .dark
            default:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }

    // MARK: - RAM Actions
    func performCleanRAM() {
        logger.info("Clean RAM initiated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            logger.info("Clean RAM completed.")
        }
    }

    func performDeepCleanRAM() {
        logger.info("Deep Clean RAM initiated.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            logger.info("Deep Clean RAM completed.")
        }
    }

    // MARK: - Placeholder Functions
    func watchAd() {
        logger.info("Ad watched.")
        adWatchCounter += 1
    }
}
