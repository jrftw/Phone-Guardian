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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // RAM Usage Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "RAM Usage", icon: "memorychip")
                    
                    RAMUsageChart(data: ramUsageData)
                        .frame(height: 200)
                        .modernCard(padding: 16)
                }
                
                // RAM Statistics Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Memory Statistics", icon: "chart.bar")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "memorychip", label: "Total RAM", value: "\(String(format: "%.1f", totalRAM)) GB", iconColor: .blue)
                        ModernInfoRow(icon: "play.fill", label: "Active RAM", value: "\(String(format: "%.1f", activeRAM)) GB", iconColor: .green)
                        ModernInfoRow(icon: "pause.fill", label: "Inactive RAM", value: "\(String(format: "%.1f", inactiveRAM)) GB", iconColor: .orange)
                        ModernInfoRow(icon: "lock.fill", label: "Wired RAM", value: "\(String(format: "%.1f", wiredRAM)) GB", iconColor: .red)
                        ModernInfoRow(icon: "arrow.down.circle", label: "Compressed RAM", value: "\(String(format: "%.1f", compressedRAM)) GB", iconColor: .purple)
                        ModernInfoRow(icon: "checkmark.circle", label: "Free RAM", value: "\(String(format: "%.1f", freeRAM)) GB", iconColor: .cyan)
                    }
                }
                .modernCard()
                
                // Detailed Chart Button
                Button(action: { isDetailedViewPresented.toggle() }) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                        Text("View Detailed RAM Information")
                    }
                }
                .modernButton(backgroundColor: .blue)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            logger.info("RAMInfoView appeared.")
            startMonitoringRAM()
        }
        .sheet(isPresented: $isDetailedViewPresented) {
            if #available(iOS 16.0, *) {
                DetailedRAMView(
                    activeRAM: activeRAM,
                    inactiveRAM: inactiveRAM,
                    wiredRAM: wiredRAM,
                    freeRAM: freeRAM,
                    compressedRAM: compressedRAM,
                    totalRAM: totalRAM
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            } else {
                DetailedRAMView(
                    activeRAM: activeRAM,
                    inactiveRAM: inactiveRAM,
                    wiredRAM: wiredRAM,
                    freeRAM: freeRAM,
                    compressedRAM: compressedRAM,
                    totalRAM: totalRAM
                )
            }
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
