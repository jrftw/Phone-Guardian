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
        VStack(alignment: .leading, spacing: 16) {
            Text("CPU Usage")
                .font(.title2)
                .bold()

            CPUUsageLineChart(userData: userData, systemData: systemData, idleData: idleData)
                .frame(height: 150)

            HStack {
                InfoRow(label: "User Usage", value: "\(Int(userUsage))%")
                InfoRow(label: "System Usage", value: "\(Int(systemUsage))%")
                InfoRow(label: "Idle Usage", value: "\(Int(idleUsage))%")
            }

            Button(action: { isDetailedViewPresented.toggle() }) {
                Text("Open Detailed View")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isDetailedViewPresented) {
                DetailedCPUView(userUsage: userUsage, systemUsage: systemUsage, idleUsage: idleUsage)
            }
        }
        .padding()
        .onAppear {
            startMonitoringCPU()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startMonitoringCPU() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            updateCPUUsage()
        }
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
