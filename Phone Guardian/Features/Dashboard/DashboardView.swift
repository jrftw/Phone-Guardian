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
            ModernLoadingView()
                .onAppear {
                    Task {
                        await preloadAppData()
                    }
                }
        } else {
            ScrollView {
                LazyVStack(spacing: 20) {
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
                            ModernModuleSummaryCard(module: module)
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

struct ModernModuleSummaryCard: View {
    let module: Module
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: module.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(module.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            HStack {
                Text("Tap for details")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

