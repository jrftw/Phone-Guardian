// CPUUsageLineChart.swift

import SwiftUI

struct CPUUsageLineChart: View {
    let userData: [Double]
    let systemData: [Double]
    let idleData: [Double]

    var body: some View {
        GeometryReader { geometry in
            let maxData = max((userData + systemData + idleData).max() ?? 1, 1)
            let stepX = geometry.size.width / CGFloat(max(userData.count - 1, 1))
            let stepY = geometry.size.height / CGFloat(maxData)

            ZStack {
                // User Usage Line
                Path { path in
                    guard userData.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(userData[0]) * stepY))
                    for index in 1..<userData.count {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(userData[index]) * stepY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                // System Usage Line
                Path { path in
                    guard systemData.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(systemData[0]) * stepY))
                    for index in 1..<systemData.count {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(systemData[index]) * stepY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.green, lineWidth: 2)

                // Idle Usage Line
                Path { path in
                    guard idleData.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(idleData[0]) * stepY))
                    for index in 1..<idleData.count {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(idleData[index]) * stepY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.gray, lineWidth: 2)
            }
        }
    }
}
