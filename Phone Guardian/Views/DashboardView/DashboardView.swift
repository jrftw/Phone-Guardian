// DashboardView.swift

import SwiftUI
import GoogleMobileAds
import os.log

struct DashboardView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var iapManager: IAPManager
    @State private var isLoading: Bool = true

    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .onAppear {
                        Task {
                            await preloadAppData()
                        }
                    }
            } else {
                VStack {
                    if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription) && !iapManager.hasRemoveAds {
                        AdBannerView()
                            .frame(height: 50)
                            .padding(.bottom, 10)
                    }

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(moduleManager.modules.filter { $0.isEnabled }) { module in
                                DashboardModuleCardView(moduleName: module.name, moduleContent: module.view)
                                    .padding(.horizontal)

                                if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription) && !iapManager.hasRemoveAds {
                                    AdBannerView()
                                        .frame(height: 50)
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Phone Guardian - Dashboard")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func preloadAppData() async {
        os_log("Starting to preload app data.")
        moduleManager.loadModules()
        await iapManager.checkSubscriptionStatus()
        await MainActor.run {
            isLoading = false
            os_log("Finished preloading app data.")
        }
    }
}

struct DashboardModuleCardView<Content: View>: View {
    let moduleName: String
    let moduleContent: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(moduleName)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 5)

            moduleContent
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.vertical, 5)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()

            Text("Initializing modules. Please wait.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}
