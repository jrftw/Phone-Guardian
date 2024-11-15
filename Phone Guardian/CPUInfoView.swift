import SwiftUI
import os

struct CPUInfoView: View {
    @State private var cpuUsageData: [Double] = [30, 45, 50, 20, 35]  // Sample Usage History
    private let logger = Logger(subsystem: "com.phoneguardian.cpu", category: "CPUInfoView")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CPU USAGE")
                .font(.title2)
                .bold()

            CPUUsageChart(data: cpuUsageData)
                .frame(height: 200)
                .padding(.vertical)

            InfoRow(label: "User Usage", value: formattedPercentage(cpuUsageData.last ?? 0))
            InfoRow(label: "System Usage", value: formattedPercentage(Double.random(in: 10...30)))
            InfoRow(label: "Idle", value: formattedPercentage(100 - (cpuUsageData.last ?? 0)))
        }
        .padding()
        .onAppear {
            logger.info("CPUInfoView appeared.")
            startMonitoringCPU()
        }
    }

    func startMonitoringCPU() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            let newUsage = Double.random(in: 20...70) // Replace this with actual CPU usage logic if available
            cpuUsageData.append(newUsage)
            if cpuUsageData.count > 10 {
                cpuUsageData.removeFirst()
            }
            logger.info("Updated CPU usage: \(newUsage)%")
        }
    }

    func formattedPercentage(_ value: Double) -> String {
        return String(format: "%.2f%%", value)
    }
}

struct CPUUsageChart: View {
    let data: [Double]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard data.count > 1 else { return }

                let stepX = geometry.size.width / CGFloat(data.count - 1)
                let maxY = data.max() ?? 1
                let stepY = geometry.size.height / CGFloat(maxY)

                path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(data[0]) * stepY))
                for index in 1..<data.count {
                    let x = CGFloat(index) * stepX
                    let y = geometry.size.height - CGFloat(data[index]) * stepY
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}
