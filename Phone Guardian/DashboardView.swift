import SwiftUI

struct DashboardView: View {
    @AppStorage("showBattery") private var showBattery = true
    @AppStorage("showDevice") private var showDevice = true
    @AppStorage("showCPU") private var showCPU = true
    @AppStorage("showRAM") private var showRAM = true
    @AppStorage("showStorage") private var showStorage = true
    @AppStorage("showNetwork") private var showNetwork = true
    @AppStorage("showSensors") private var showSensors = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if showDevice { DeviceInfoView() }
                if showBattery { BatteryInfoView() }
                if showCPU { CPUInfoView() }
                if showRAM { RAMInfoView() }
                if showStorage { StorageInfoView() }
                if showNetwork { NetworkInfoView() }
                if showSensors { SensorInfoView() }
            }
            .padding()
        }
    }
}
