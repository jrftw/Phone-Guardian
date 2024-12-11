// RamPieChart.swift
import SwiftUI

struct RamPieChart: View {
    let activeRAM: Double
    let inactiveRAM: Double
    let wiredRAM: Double
    let freeRAM: Double
    let compressedRAM: Double
    let totalRAM: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let total = activeRAM + inactiveRAM + wiredRAM + freeRAM + compressedRAM
                let slices = [
                    (value: activeRAM / total, color: Color.blue, label: "Active"),
                    (value: inactiveRAM / total, color: Color.green, label: "Inactive"),
                    (value: wiredRAM / total, color: Color.orange, label: "Wired"),
                    (value: compressedRAM / total, color: Color.purple, label: "Compressed"),
                    (value: freeRAM / total, color: Color.gray, label: "Free")
                ]

                var startDegree: Double = 0
                let sliceData = slices.map { slice -> SliceData in
                    let endDegree = startDegree + slice.value * 360
                    let data = SliceData(
                        startAngle: Angle(degrees: startDegree),
                        endAngle: Angle(degrees: endDegree),
                        color: slice.color,
                        label: slice.label,
                        value: slice.value
                    )
                    startDegree = endDegree
                    return data
                }

                ForEach(sliceData.indices, id: \.self) { index in
                    let slice = sliceData[index]
                    RamPieSliceView(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(slice.color)
                }

                VStack {
                    Text("RAM Breakdown")
                        .font(.headline)
                    ForEach(sliceData, id: \.label) { slice in
                        Text("\(slice.label): \(Int(slice.value * 100))%")
                    }
                }
                .font(.caption)
                .foregroundColor(.white)
            }
        }
    }
}

struct SliceData {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let label: String
    let value: Double
}

struct RamPieSliceView: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle - Angle(degrees: 90),
            endAngle: endAngle - Angle(degrees: 90),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}
