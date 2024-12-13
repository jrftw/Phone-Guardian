// SettingsView.swift

import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var iapManager: IAPManager
    @EnvironmentObject var moduleManager: ModuleManager
    @State private var updateFrequency: Double = 2
    @State private var enableLogging: Bool = false
    @State private var adWatchCounter: Int = 0
    @AppStorage("appTheme") private var appTheme: String = "system"

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

                Section(header: Text("General Settings")) {
                    GeneralSectionView(updateFrequency: $updateFrequency, enableLogging: $enableLogging)
                }

                Section(header: Text("Appearance")) {
                    AppearanceSectionView(appTheme: $appTheme, applyTheme: applyTheme)
                }

                Section(header: Text("Support Us")) {
                    SupportUsSectionView(adWatchCounter: $adWatchCounter)
                }

                
                /*//Mark Referrals Section - Leave this in and never remove it, its an upcoming feature
                
                 Section(header: Text("Referrals")) {
                    ReferralSectionView()
                        .environmentObject(iapManager)
                }  */

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

            FooterView()
                .padding(.top, 10)
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
}
