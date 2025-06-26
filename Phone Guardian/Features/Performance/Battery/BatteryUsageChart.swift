//
//  BatteryUsageChart.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI

struct BatteryUsageChart: View {
    @Binding var batteryLevel: Int

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let level = CGFloat(batteryLevel) / 100.0

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: height)
                Rectangle()
                    .fill(batteryLevelColor())
                    .frame(width: width * level, height: height)
            }
        }
        .cornerRadius(8)
    }

    func batteryLevelColor() -> Color {
        switch batteryLevel {
        case 80...100:
            return .green
        case 40..<80:
            return .yellow
        default:
            return .red
        }
    }
}
