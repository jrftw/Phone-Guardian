// NetworkUsageChart.swift

import SwiftUI

struct NetworkUsageChart: View {
    let uploadHistory: [Double]
    let downloadHistory: [Double]

    var body: some View {
        GeometryReader { geometry in
            let maxData = max((uploadHistory + downloadHistory).max() ?? 1, 1)
            let stepX = geometry.size.width / CGFloat(max(uploadHistory.count - 1, 1))
            let stepY = geometry.size.height / CGFloat(maxData)

            ZStack {
                // Upload Speed Line
                Path { path in
                    guard uploadHistory.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(uploadHistory[0]) * stepY))
                    for index in 1..<uploadHistory.count {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(uploadHistory[index]) * stepY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.green, lineWidth: 2)

                // Download Speed Line
                Path { path in
                    guard downloadHistory.count > 1 else { return }
                    path.move(to: CGPoint(x: 0, y: geometry.size.height - CGFloat(downloadHistory[0]) * stepY))
                    for index in 1..<downloadHistory.count {
                        let x = CGFloat(index) * stepX
                        let y = geometry.size.height - CGFloat(downloadHistory[index]) * stepY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
            }
        }
    }
}
