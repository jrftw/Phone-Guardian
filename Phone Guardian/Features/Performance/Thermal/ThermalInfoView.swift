import SwiftUI

struct ThermalInfoView: View {
    @StateObject private var thermalManager = ThermalManagementManager.shared
    @State private var isMonitoring = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Thermal Overview Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Thermal Overview", icon: "thermometer")
                    
                    LazyVStack(spacing: 8) {
                        ModernInfoRow(icon: "thermometer", label: "Current Temperature", value: String(format: "%.1f°C", thermalManager.currentTemperature), iconColor: thermalManager.getTemperatureColor(thermalManager.currentTemperature))
                        ModernInfoRow(icon: "flame", label: "Thermal State", value: thermalManager.getThermalStateDescription(thermalManager.thermalState), iconColor: thermalManager.getThermalStateColor(thermalManager.thermalState))
                        ModernInfoRow(icon: "clock", label: "Last Update", value: formatDate(thermalManager.lastUpdateDate), iconColor: .blue)
                    }
                }
                .modernCard()
                
                // Temperature History Chart Section
                if !thermalManager.temperatureHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        ModernSectionHeader(title: "Temperature History (Last 200s)", icon: "chart.line.uptrend.xyaxis")
                        TemperatureLineChart(history: thermalManager.temperatureHistory)
                            .frame(height: 180)
                            .modernCard(padding: 12)
                    }
                }
                
                // Alerts Section
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Thermal Alerts", icon: "exclamationmark.triangle")
                    
                    if thermalManager.thermalAlerts.isEmpty {
                        Text("No alerts detected")
                            .foregroundColor(.green)
                            .padding()
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(thermalManager.thermalAlerts.suffix(5)) { alert in
                                ThermalAlertRow(alert: alert)
                            }
                        }
                    }
                }
                .modernCard()
                
                // Action Buttons
                VStack(alignment: .leading, spacing: 16) {
                    ModernSectionHeader(title: "Actions", icon: "wrench.and.screwdriver")
                    
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            Task {
                                if isMonitoring {
                                    thermalManager.stopMonitoring()
                                } else {
                                    await thermalManager.startMonitoring()
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
                            thermalManager.clearTemperatureHistory()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Temperature History")
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
        .navigationTitle("Thermal Info")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await thermalManager.startMonitoring()
                isMonitoring = true
            }
        }
        .onDisappear {
            thermalManager.stopMonitoring()
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

struct TemperatureLineChart: View {
    let history: [ThermalManagementManager.TemperaturePoint]
    
    var body: some View {
        GeometryReader { geometry in
            let maxTemp = history.map { $0.temperature }.max() ?? 100
            let minTemp = history.map { $0.temperature }.min() ?? 0
            let points = history.enumerated().map { (i, point) in
                CGPoint(
                    x: geometry.size.width * CGFloat(i) / CGFloat(max(history.count - 1, 1)),
                    y: geometry.size.height * (1 - CGFloat((point.temperature - minTemp) / max(1, maxTemp - minTemp)))
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

struct ThermalAlertRow: View {
    let alert: ThermalManagementManager.ThermalAlert
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: alertIcon)
                .foregroundColor(alertColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text("\(formatDate(alert.timestamp)) • \(typeText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(severityText)
                .font(.caption)
                .foregroundColor(alertColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var alertIcon: String {
        switch alert.severity {
        case .critical: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.triangle"
        case .medium: return "exclamationmark.circle"
        case .low: return "info.circle"
        }
    }
    
    private var alertColor: Color {
        switch alert.severity {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var severityText: String {
        switch alert.severity {
        case .critical: return "Critical"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
    
    private var typeText: String {
        switch alert.type {
        case .overheating: return "Overheating"
        case .highTemperature: return "High Temp"
        case .thermalThrottling: return "Throttling"
        case .thermalStateChange: return "State Change"
        }
    }
} 