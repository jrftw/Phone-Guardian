import SwiftUI
import os

struct DetailedDeviceInfoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Device Categories").font(.headline)) {
                    NavigationLink("View iPhones", destination: DetailediPhoneView())
                    NavigationLink("View iPads", destination: DetailediPadView())
                    NavigationLink("View Macs", destination: DetailedMacView())
                    NavigationLink("View Vision Pro", destination: DetailedVisionProView())
                }
            }
            .navigationTitle("Detailed Device Info")
            .onAppear {
                Logger(subsystem: "com.phoneguardian.detaileddeviceinfo", category: "DetailedDeviceInfoView")
                    .info("Loaded DetailedDeviceInfoView")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures full screen on iPad
    }
}
