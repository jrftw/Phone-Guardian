//
//  MultiTouchTestView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/26/24.
//
/*
import SwiftUI

struct MultiTouchTestView: View {
    @State private var touchPoints: [HashableCGPoint] = [] // Use Hashable wrapper

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let point = HashableCGPoint(value.location)
                                if !touchPoints.contains(point) {
                                    touchPoints.append(point)
                                }
                            }
                            .onEnded { _ in
                                touchPoints.removeAll()
                            }
                    )

                ForEach(touchPoints, id: \.self) { hashablePoint in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .position(hashablePoint.point)
                }

                Text("Touch anywhere with multiple fingers to test multi-touch functionality.")
                    .font(.body)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
            }
        }
        .navigationTitle("Multi-Touch Test")
    }
}

// MARK: - Hashable Wrapper for CGPoint
struct HashableCGPoint: Hashable {
    let x: CGFloat
    let y: CGFloat

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    var point: CGPoint {
        return CGPoint(x: x, y: y)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }

    static func == (lhs: HashableCGPoint, rhs: HashableCGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
 */
