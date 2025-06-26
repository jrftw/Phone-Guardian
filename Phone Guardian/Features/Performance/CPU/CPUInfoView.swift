import SwiftUI
import os

struct CPUInfoView: View {
    @State private var userUsage: Double = 0
    @State private var systemUsage: Double = 0
    @State private var idleUsage: Double = 0
    @State private var userData: [Double] = []
    @State private var systemData: [Double] = []
    @State private var idleData: [Double] = []
    @State private var isDetailedViewPresented = false
    @State private var timer: Timer?

    private let logger = Logger(subsystem: "com.phoneguardian.cpu", category: "CPUInfoView")

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // CPU Usage Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "CPU Usage", icon: "cpu")
                    
                    CPUUsageLineChart(userData: userData, systemData: systemData, idleData: idleData)
                        .frame(height: 200)
                        .modernCard(padding: 16)
                }
                
                // CPU Usage Stats Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Usage Statistics", icon: "chart.bar")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "person", label: "User Usage", value: "\(Int(userUsage))%", iconColor: .blue)
                        ModernInfoRow(icon: "gear", label: "System Usage", value: "\(Int(systemUsage))%", iconColor: .orange)
                        ModernInfoRow(icon: "sleep", label: "Idle Usage", value: "\(Int(idleUsage))%", iconColor: .green)
                    }
                }
                .modernCard()
                
                // Detailed View Button
                Button(action: { isDetailedViewPresented.toggle() }) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                        Text("View Detailed CPU Information")
                    }
                }
                .modernButton(backgroundColor: .blue)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .onAppear {
            startMonitoringCPU()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .sheet(isPresented: $isDetailedViewPresented) {
            if #available(iOS 16.0, *) {
                DetailedCPUView(userUsage: userUsage, systemUsage: systemUsage, idleUsage: idleUsage)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            } else {
                DetailedCPUView(userUsage: userUsage, systemUsage: systemUsage, idleUsage: idleUsage)
            }
        }
    }

    private func startMonitoringCPU() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            updateCPUUsage()
        }
        updateCPUUsage() // Initial update
    }

    private func updateCPUUsage() {
        let usage = getCPUUsage()
        DispatchQueue.main.async {
            userUsage = usage.user
            systemUsage = usage.system
            idleUsage = usage.idle

            userData.append(userUsage)
            systemData.append(systemUsage)
            idleData.append(idleUsage)

            if userData.count > 10 {
                userData.removeFirst()
                systemData.removeFirst()
                idleData.removeFirst()
            }
        }
    }

    private func getCPUUsage() -> (user: Double, system: Double, idle: Double) {
        // Placeholder for actual CPU usage logic
        let total = 100.0
        let user = Double.random(in: 20...40)
        let system = Double.random(in: 10...30)
        let idle = total - user - system
        return (user: user, system: system, idle: idle)
    }
}
