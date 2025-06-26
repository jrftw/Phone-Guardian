// ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var showRatingPrompt = false

    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }

            NavigationView {
                AddOnsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Add-Ons", systemImage: "cart")
            }

            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .sheet(isPresented: $showRatingPrompt) {
            RatingPromptView(isPresented: $showRatingPrompt)
        }
        .onAppear {
            checkAndShowRatingPrompt()
        }
    }

    private func checkAndShowRatingPrompt() {
        let hasRated = UserDefaults.standard.bool(forKey: "hasRatedApp")
        guard !hasRated else { return }

        let launches = UserDefaults.standard.integer(forKey: "launches") + 1
        UserDefaults.standard.set(launches, forKey: "launches")

        if launches % 5 == 0 {
            showRatingPrompt = true
        }
    }
}
