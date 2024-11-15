import SwiftUI

struct SettingsView: View {
    @AppStorage("showBattery") private var showBattery = true
    @AppStorage("showNetwork") private var showNetwork = true
    @AppStorage("showDevice") private var showDevice = true
    @AppStorage("showCamera") private var showCamera = true
    @AppStorage("showRAM") private var showRAM = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("showCPU") private var showCPU = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Modules")) {
                    Toggle("Show Battery Info", isOn: $showBattery)
                    Toggle("Show Network Info", isOn: $showNetwork)
                    Toggle("Show Device Info", isOn: $showDevice)
                    Toggle("Show Camera Info", isOn: $showCamera)
                    Toggle("Show RAM Info", isOn: $showRAM)
                    Toggle("Show Storage Info", isOn: $showStorage)
                    Toggle("Show CPU Info", isOn: $showCPU)
                }

                Section(header: Text("Individual Views")) {
                    NavigationLink("Battery Info") { BatteryInfoView() }
                    NavigationLink("Network Info") { NetworkInfoView() }
                    NavigationLink("Device Info") { DeviceInfoView() }
                    NavigationLink("Camera Info") { CameraView() }
                    NavigationLink("RAM Info") { RAMInfoView() }
                    NavigationLink("Storage Info") { StorageInfoView() }
                    NavigationLink("CPU Info") { CPUInfoView() }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
