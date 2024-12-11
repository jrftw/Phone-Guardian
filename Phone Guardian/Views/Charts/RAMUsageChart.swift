// RAMUsageChart.swift
import SwiftUI

struct RAMUsageChart: View {
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
            .stroke(Color.green, lineWidth: 2)
        }
    }
}
