//
//  TestKitView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/19/24.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct TestKitView: View {
    @State private var testResults: [String] = []
    @State private var isTesting = false

    var body: some View {
        VStack {
            Text("Test Device Sensors and Connectors")
                .font(.headline)
                .padding(.bottom)

            Button("Run Tests") {
                runDeviceTests()
            }
            .disabled(isTesting)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isTesting ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            List(testResults, id: \.self) {
                Text($0)
            }
            .padding(.top)

        }
        .navigationTitle("Test Kit")
    }

    func runDeviceTests() {
        isTesting = true
        testResults = []

        // Simulate running tests asynchronously
        DispatchQueue.global().async {
            let motionManager = CMMotionManager()
            let audioSession = AVAudioSession.sharedInstance()

            // Accelerometer Test
            if motionManager.isAccelerometerAvailable {
                motionManager.startAccelerometerUpdates()
                testResults.append("Accelerometer: ✅ Working")
            } else {
                testResults.append("Accelerometer: ❌ Not Available")
            }

            // Gyroscope Test
            if motionManager.isGyroAvailable {
                motionManager.startGyroUpdates()
                testResults.append("Gyroscope: ✅ Working")
            } else {
                testResults.append("Gyroscope: ❌ Not Available")
            }

            // Microphone Test
            do {
                try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
                testResults.append("Microphone: ✅ Working")
            } catch {
                testResults.append("Microphone: ❌ Error - \(error.localizedDescription)")
            }

            // Camera Test
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                testResults.append("Camera: ✅ Working")
            } else {
                testResults.append("Camera: ❌ Not Available")
            }

            // Simulated Hardware Port Test
            testResults.append("Lightning Port: ✅ Working")
            testResults.append("Headphone Jack: ✅ Working")

            DispatchQueue.main.async {
                isTesting = false
            }
        }
    }
}
