//
//  CameraView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/15/24.
//


import SwiftUI

struct CameraView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CAMERA")
                .font(.title2)
                .bold()

            InfoRow(label: "Telephoto Sensor", value: "✔︎")
            InfoRow(label: "Wide Sensor", value: "✔︎")
            InfoRow(label: "Ultra-Wide Sensor", value: "✔︎")
            InfoRow(label: "Lidar", value: "✔︎")
            InfoRow(label: "Flashlight", value: "✔︎")
        }
        .padding()
    }
}