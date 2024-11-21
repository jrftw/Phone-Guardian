import SwiftUI

struct CPUPieChartView: View {
    let user: Double
    let system: Double
    let idle: Double

    var body: some View {
        GeometryReader { geometry in
            let totalAngle = 360.0
            let userAngle = user / 100 * totalAngle
            let systemAngle = system / 100 * totalAngle

            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .foregroundColor(.gray.opacity(0.2))

                // User Slice
                PieSliceView(startAngle: .degrees(0), endAngle: .degrees(userAngle))
                    .fill(Color.blue)

                // System Slice
                PieSliceView(startAngle: .degrees(userAngle), endAngle: .degrees(userAngle + systemAngle))
                    .fill(Color.green)

                // Idle Slice
                PieSliceView(startAngle: .degrees(userAngle + systemAngle), endAngle: .degrees(totalAngle))
                    .fill(Color.orange)

                VStack {
                    Text("User: \(Int(user))%")
                    Text("System: \(Int(system))%")
                    Text("Idle: \(Int(idle))%")
                }
                .font(.caption)
            }
            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct PieSliceView: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.move(to: center)
        path.addArc(center: center, radius: radius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
}
