import SwiftUI
import GoogleMobileAds
import os.log

struct DashboardView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var iapManager: IAPManager
    @State private var isLoading: Bool = true
    @State private var selectedModule: Module?
    
    var body: some View {
        if isLoading {
            LoadingView()
                .onAppear {
                    Task {
                        await preloadAppData()
                    }
                }
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    if !(iapManager.hasGoldSubscription || iapManager.hasToolsSubscription) && !iapManager.hasRemoveAds {
                        AdBannerView()
                            .frame(height: 50)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(moduleManager.modules.filter { $0.isEnabled }) { module in
                            ModuleSummaryCard(module: module)
                                .onTapGesture {
                                    selectedModule = module
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Phone Guardian")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(item: $selectedModule) { module in
                NavigationView {
                    module.view
                    .navigationTitle(module.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                selectedModule = nil
                            }
                        }
                    }
                }
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

struct ModuleSummaryCard: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: module.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.accentColor)
                Text(module.name)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                Spacer()
            }
            Text(module.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
            // Placeholder for a key stat (can be replaced with real data per module)
            Text("Tap for details")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(minHeight: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 2)
        )
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Initializing modules...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

