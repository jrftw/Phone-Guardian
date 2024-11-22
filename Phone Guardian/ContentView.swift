import SwiftUI

struct ContentView: View {
    @AppStorage("showBattery") private var showBattery = true
    @AppStorage("showDevice") private var showDevice = true
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showRAM") private var showRAM = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("showNetwork") private var showNetwork = true
    @AppStorage("showSensors") private var showSensors = true

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
