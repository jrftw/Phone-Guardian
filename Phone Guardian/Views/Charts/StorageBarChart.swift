//
//  StorageBarChart.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/9/24.
//


// StorageBarChart.swift

import SwiftUI

struct StorageBarChart: View {
    let usedPercentage: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: geometry.size.height)
                Rectangle()
                    .fill(usedPercentage > 80 ? Color.red : usedPercentage > 50 ? Color.orange : Color.green)
                    .frame(width: geometry.size.width * CGFloat(usedPercentage / 100), height: geometry.size.height)
            }
            .cornerRadius(5)
        }
    }
}