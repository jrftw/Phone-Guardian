//
//  CameraView.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/20/24.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State private var telephotoEnabled = false
    @State private var lidarEnabled = false
    @State private var wideEnabled = false
    @State private var ultraWideEnabled = false
    @State private var flashlightEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Camera Information")
                .font(.title2)
                .bold()

            // Display camera feature availability
            InfoRow(label: "Telephoto Sensor", value: telephotoEnabled ? "Available" : "Not Available")
            InfoRow(label: "LiDAR", value: lidarEnabled ? "Available" : "Not Available")
            InfoRow(label: "Wide Sensor", value: wideEnabled ? "Available" : "Not Available")
            InfoRow(label: "Ultra-Wide Sensor", value: ultraWideEnabled ? "Available" : "Not Available")
            InfoRow(label: "Flashlight", value: flashlightEnabled ? "Available" : "Not Available")

            // Button to navigate to CameraInfoView
            NavigationLink(destination: CameraInfoView()) {
                Text("More Info")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            checkCameraFeatures()
        }
    }

    // MARK: - Camera Feature Detection
    private func checkCameraFeatures() {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInTelephotoCamera, .builtInLiDARDepthCamera, .builtInWideAngleCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .unspecified
        )

        for device in discoverySession.devices {
            switch device.deviceType {
            case .builtInTelephotoCamera:
                telephotoEnabled = true
            case .builtInLiDARDepthCamera:
                lidarEnabled = true
            case .builtInWideAngleCamera:
                wideEnabled = true
            case .builtInUltraWideCamera:
                ultraWideEnabled = true
            default:
                break
            }
        }

        flashlightEnabled = AVCaptureDevice.default(for: .video)?.hasTorch ?? false
    }
}
