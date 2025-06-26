// SettingsView.swift

import SwiftUI
import UIKit
import StoreKit
import os.log

struct SettingsView: View {
    @EnvironmentObject var iapManager: IAPManager
    @EnvironmentObject var moduleManager: ModuleManager
    @State private var updateFrequency: Double = 2
    @State private var enableLogging: Bool = false
    @State private var adWatchCounter: Int = 0
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("temperatureMetric") private var temperatureMetric = "Fahrenheit"
    @State private var showingResetAlert = false
    @State private var showingAboutSheet = false
    
    private let logger = Logger(subsystem: "com.phoneguardian.settings", category: "SettingsView")

    var body: some View {
        VStack(spacing: 0) {
            List {
                if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription) && !iapManager.hasRemoveAds {
                    AdBannerView()
                        .frame(height: 50)
                        .listRowInsets(EdgeInsets())
                }

                Section(header: Text("Modules")) {
                    NavigationLink(destination: ManageModulesView()) {
                        Text("Manage Modules")
                    }
                }

                Section(header: Text("General")) {
                    Toggle("Enable Logging", isOn: $enableLogging)
                        .onChange(of: enableLogging) { newValue in
                            logger.info("Logging \(newValue ? "enabled" : "disabled")")
                        }
                    
                    Picker("Temperature Unit", selection: $temperatureMetric) {
                        Text("Fahrenheit").tag("Fahrenheit")
                        Text("Celsius").tag("Celsius")
                    }
                }

                Section(header: Text("Appearance")) {
                    AppearanceSectionView(appTheme: $appTheme, applyTheme: applyTheme)
                }

                Section(header: Text("Support")) {
                    Button(action: { showingAboutSheet = true }) {
                        Label("About Phone Guardian", systemImage: "info.circle")
                    }
                    
                    Link(destination: URL(string: "https://phoneguardian.app/support")!) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    Button(action: { showingResetAlert = true }) {
                        Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.red)
                    }
                }

                Section(header: Text("Subscriptions")) {
                    if iapManager.hasGoldSubscription {
                        Label("Gold Subscription Active", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    if iapManager.hasToolsSubscription {
                        Label("Tools Subscription Active", systemImage: "wrench.fill")
                            .foregroundColor(.blue)
                    }
                    if iapManager.hasRemoveAds {
                        Label("Ads Removed", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                Section(header: Text("Support Us")) {
                    SupportUsSectionView(adWatchCounter: $adWatchCounter)
                }

                Section(header: Text("Referrals")) {
                    ReferralSectionView()
                        .environmentObject(iapManager)
                }

                Section(header: Text("Account")) {
                    Button(action: {
                        Task {
                            await iapManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .foregroundColor(.blue)
                    }
                }

                OtherSectionView()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .onAppear {
                applyTheme(appTheme)
            }

            Spacer(minLength: 0)
            FooterView()
                .padding(.top, 10)
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values?")
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }

    private func applyTheme(_ theme: String) {
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

    private func resetSettings() {
        enableLogging = false
        temperatureMetric = "Fahrenheit"
        UserDefaults.standard.synchronize()
        logger.info("Settings reset to defaults")
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Phone Guardian")
                            .font(.title)
                            .bold()
                        
                        Text("Version 1.12 Build 1")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section(header: Text("About")) {
                    Text("Phone Guardian helps you monitor and maintain your device's health and performance.")
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Legal")) {
                    Link("Privacy Policy", destination: URL(string: "https://phoneguardian.app/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://phoneguardian.app/terms")!)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss sheet
                    }
                }
            }
        }
    }
}
