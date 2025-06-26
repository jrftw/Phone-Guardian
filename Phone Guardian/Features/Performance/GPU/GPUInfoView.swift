import SwiftUI

struct GPUInfoView: View {
    @StateObject private var gpuManager = GPUMonitoringManager.shared
    @State private var isMonitoring = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // GPU Overview Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "GPU Overview", icon: "gpu")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "gpu", label: "GPU Name", value: gpuManager.gpuInfo.name, iconColor: .blue)
                        ModernInfoRow(icon: "cpu", label: "Cores", value: "\(gpuManager.gpuInfo.cores)", iconColor: .green)
                        ModernInfoRow(icon: "memorychip", label: "Memory", value: gpuManager.gpuInfo.memory, iconColor: .purple)
                        ModernInfoRow(icon: "bolt", label: "Architecture", value: gpuManager.gpuInfo.architecture, iconColor: .orange)
                        ModernInfoRow(icon: "speedometer", label: "Max Frequency", value: gpuManager.formatFrequency(gpuManager.gpuInfo.maxFrequency), iconColor: .red)
                        ModernInfoRow(icon: "speedometer", label: "Current Frequency", value: gpuManager.formatFrequency(gpuManager.gpuInfo.currentFrequency), iconColor: .yellow)
                    }
                }
                .modernCard()
                
                // GPU Monitoring Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "GPU Monitoring", icon: "waveform.path.ecg")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "speedometer", label: "GPU Usage", value: String(format: "%.1f%%", gpuManager.gpuUsage), iconColor: gpuManager.getGPUUsageColor())
                        ModernInfoRow(icon: "chart.bar", label: "GPU Load", value: String(format: "%.1f%%", gpuManager.gpuLoad), iconColor: gpuManager.getGPULoadColor())
                        ModernInfoRow(icon: "thermometer", label: "Temperature", value: String(format: "%.1f°C", gpuManager.gpuTemperature), iconColor: gpuManager.getGPUTemperatureColor())
                        ModernInfoRow(icon: "clock", label: "Last Update", value: formatDate(gpuManager.lastUpdateDate), iconColor: .blue)
                    }
                }
                .modernCard()
                
                // GPU Activity Chart Section
                if !gpuManager.gpuActivity.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "GPU Activity (Last 100s)", icon: "chart.line.uptrend.xyaxis")
                        GPUUsageLineChart(activity: gpuManager.gpuActivity)
                            .frame(height: 180)
                            .modernCard(padding: 12)
                    }
                }
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                if isMonitoring {
                                    gpuManager.stopMonitoring()
                                } else {
                                    await gpuManager.startMonitoring()
                                }
                                isMonitoring.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: isMonitoring ? "pause.circle" : "play.circle")
                                Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                            }
                        }
                        .modernButton(backgroundColor: isMonitoring ? .orange : .green)
                        
                        Button(action: {
                            gpuManager.clearActivityData()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Activity Data")
                            }
                        }
                        .modernButton(backgroundColor: .red)
                    }
                }
                .modernCard()
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("GPU Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await gpuManager.startMonitoring()
                isMonitoring = true
            }
        }
        .onDisappear {
            gpuManager.stopMonitoring()
            isMonitoring = false
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GPUUsageLineChart: View {
    let activity: [GPUMonitoringManager.GPUActivityPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let maxUsage = activity.map { $0.usage }.max() ?? 100
            let points = activity.enumerated().map { (i, point) in
                CGPoint(
                    x: geometry.size.width * CGFloat(i) / CGFloat(max(activity.count - 1, 1)),
                    y: geometry.size.height * (1 - CGFloat(point.usage / maxUsage))
                )
            }
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for point in points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.accentColor, lineWidth: 2)
        }
    }
} 