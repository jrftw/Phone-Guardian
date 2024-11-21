import SwiftUI
import GoogleMobileAds

struct DashboardView: View {
    @State private var modules = [
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
    @StateObject private var iapManager = IAPManager.shared // Manages in-app purchases

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Display Ad Banner
                if !Environment.isSimulator {
                    AdBannerView()
                        .frame(height: 50)
                }

                // Scrollable Main Content
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(modules.indices, id: \.self) { index in
                            if activeModules[index] {
                                modules[index].view
                            }
                        }
                    }
                    .padding()
                }

                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    NavigationLink(destination: DashboardView()) {
                        VStack {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 30, height: 30) // Increased size
                            Text("Dashboard")
                                .font(.footnote) // Adjusted font size
                        }
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        VStack {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 30, height: 30) // Increased size
                            Text("Settings")
                                .font(.footnote) // Adjusted font size
                        }
                    }
                    Spacer()
                    // Conditionally display the Gold tab if the user has purchased Gold
                    if iapManager.hasGoldSubscription {
                        NavigationLink(destination: GoldFeaturesView()) {
                            VStack {
                                Image(systemName: "star.fill") // Icon for Gold
                                    .resizable()
                                    .frame(width: 30, height: 30) // Increased size
                                    .foregroundColor(.yellow)
                                Text("Gold")
                                    .font(.footnote) // Adjusted font size
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
            }
            .navigationTitle("Phone Guardian - Protect") // Corrected title
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
