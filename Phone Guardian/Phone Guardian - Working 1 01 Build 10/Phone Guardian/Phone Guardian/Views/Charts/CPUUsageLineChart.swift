import SwiftUI

struct CPUUsageLineChart: View {
    let userData: [Double]
    let systemData: [Double]
    let idleData: [Double]

    var body: some View {
        GeometryReader { geometry in
            let stepX = geometry.size.width / CGFloat(max(userData.count - 1, 1))
            let maxY = 100.0
            let stepY = geometry.size.height / maxY

            ZStack {
                // Gridlines
                ForEach(0..<5) { i in
                    let y = CGFloat(i) * geometry.size.height / 4
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2))
                }

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
                .stroke(Color.orange, lineWidth: 2)
            }
        }
    }
}
