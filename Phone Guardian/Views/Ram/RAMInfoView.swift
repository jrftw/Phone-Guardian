// RAMInfoView.swift
import SwiftUI
import os

struct RAMInfoView: View {
    @State private var totalRAM: Double = getTotalRAM()
    @State private var activeRAM: Double = 0.0
    @State private var inactiveRAM: Double = 0.0
    @State private var wiredRAM: Double = 0.0
    @State private var compressedRAM: Double = 0.0
    @State private var freeRAM: Double = 0.0
    @State private var ramUsageData: [Double] = []
    @State private var isDetailedViewPresented = false

    private let logger = Logger(subsystem: "com.phoneguardian.ram", category: "RAMInfoView")
    @AppStorage("enableLogging") private var enableLogging: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("RAM")
                .font(.title2)
                .bold()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Total RAM", value: "\(String(format: "%.1f", totalRAM)) GB")
                    InfoRow(label: "Active RAM", value: "\(String(format: "%.1f", activeRAM)) GB")
                    InfoRow(label: "Inactive RAM", value: "\(String(format: "%.1f", inactiveRAM)) GB")
                    InfoRow(label: "Wired RAM", value: "\(String(format: "%.1f", wiredRAM)) GB")
                    InfoRow(label: "Compressed RAM", value: "\(String(format: "%.1f", compressedRAM)) GB")
                }

                RAMUsageChart(data: ramUsageData)
                    .frame(height: 200)
            }

            Button(action: { isDetailedViewPresented.toggle() }) {
                Text("Detailed Chart")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isDetailedViewPresented) {
                DetailedRAMView(
                    activeRAM: activeRAM,
                    inactiveRAM: inactiveRAM,
                    wiredRAM: wiredRAM,
                    freeRAM: freeRAM,
                    compressedRAM: compressedRAM,
                    totalRAM: totalRAM
                )
            }

            Divider()
        }
        .padding()
        .onAppear {
            logger.info("RAMInfoView appeared.")
            startMonitoringRAM()
        }
    }

    // MARK: - RAM Monitoring Functions

    func startMonitoringRAM() {
        updateRAMUsage()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            updateRAMUsage()
        }
    }

    func updateRAMUsage() {
        let stats = getRAMUsage()

        DispatchQueue.main.async {
            self.activeRAM = stats.activeRAM
            self.inactiveRAM = stats.inactiveRAM
            self.wiredRAM = stats.wiredRAM
            self.compressedRAM = stats.compressedRAM
            self.freeRAM = stats.freeRAM
            self.ramUsageData.append(totalRAM - self.freeRAM)

            if self.ramUsageData.count > 10 {
                self.ramUsageData.removeFirst()
            }

            logger.info("RAM usage updated.")
        }
    }

    static func getTotalRAM() -> Double {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        return Double(physicalMemory) / 1_073_741_824 // Convert bytes to GB
    }

    func getRAMUsage() -> (activeRAM: Double, inactiveRAM: Double, wiredRAM: Double, compressedRAM: Double, freeRAM: Double) {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let hostPort = mach_host_self()
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }

        if result != KERN_SUCCESS {
            logger.error("Failed to fetch VM statistics.")
            return (0, 0, 0, 0, 0)
        }

        let pageSize = vm_kernel_page_size

        let active = Double(vmStats.active_count) * Double(pageSize) / 1_073_741_824
        let inactive = Double(vmStats.inactive_count) * Double(pageSize) / 1_073_741_824
        let wired = Double(vmStats.wire_count) * Double(pageSize) / 1_073_741_824
        let compressed = Double(vmStats.compressor_page_count) * Double(pageSize) / 1_073_741_824
        let free = Double(vmStats.free_count) * Double(pageSize) / 1_073_741_824

        return (activeRAM: active, inactiveRAM: inactive, wiredRAM: wired, compressedRAM: compressed, freeRAM: free)
    }
}
