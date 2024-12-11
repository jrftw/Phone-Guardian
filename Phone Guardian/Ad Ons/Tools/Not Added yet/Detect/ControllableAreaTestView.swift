//
//  ControllableAreaTestView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/26/24.
//
/*
import SwiftUI

// Wrapper struct to make CGPoint hashable for iOS versions earlier than 18.0
struct HashableCGPoint: Hashable {
    let point: CGPoint

    func hash(into hasher: inout Hasher) {
        hasher.combine(point.x)
        hasher.combine(point.y)
    }

    static func == (lhs: HashableCGPoint, rhs: HashableCGPoint) -> Bool {
        return lhs.point == rhs.point
    }
}

struct ControllableAreaTestView: View {
    @State private var touchPoints: [HashableCGPoint] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newPoint = HashableCGPoint(point: value.location)
                                if !touchPoints.contains(newPoint) {
                                    touchPoints.append(newPoint)
                                }
                            }
                            .onEnded { _ in
                                touchPoints.removeAll()
                            }
                    )

                ForEach(touchPoints, id: \.self) { hashablePoint in
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(hashablePoint.point)
                }

                Text("Touch anywhere to ensure the entire screen is responsive.")
                    .font(.body)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
            }
        }
        .navigationTitle("Controllable Area Test")
    }
}
 */
