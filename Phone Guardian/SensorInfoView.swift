//
//  SensorInfoView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/15/24.
//


import SwiftUI
import CoreMotion
import CoreNFC

struct SensorInfoView: View {
    let sensors = [
        ("Face ID", true),
        ("Touch ID", false),
        ("Accelerometer", CMMotionManager().isAccelerometerAvailable),
        ("Gyroscope", CMMotionManager().isGyroAvailable),
        ("Magnetometer", CMMotionManager().isMagnetometerAvailable),
        ("NFC", NFCReaderSession.readingAvailable)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SENSOR")
                .font(.title2)
                .bold()
            
            ForEach(sensors, id: \.0) { sensor in
                InfoRow(label: sensor.0, value: sensor.1 ? "✔︎" : "✘")
            }
        }
        .padding()
    }
}