import SwiftUI

struct DetailedVisionProView: View {
    // MARK: - Device Data
    let devices: [Device] = [
        // Apple Vision Pro
        Device(
            name: "Apple Vision Pro",
            releaseDate: "Expected Early 2024",
            specifications: [
                "Model Numbers": "N301",
                "Processor": "Apple M2 with 8-core CPU and 10-core GPU; Apple R1 coprocessor",
                "Memory": "16 GB unified memory",
                "Storage": "256 GB, 512 GB, 1 TB",
                "Display": "Dual micro-OLED displays with a total of 23 million pixels; 7.5-micron pixel pitch; 90Hz, 96Hz, 100Hz refresh rates",
                "Operating System": "visionOS",
                "Colors": "Aluminum frame with a curved laminated glass front",
                "Weight": "600–650 grams (21.2–22.9 ounces), depending on Light Seal and headband configuration",
                "Battery": "Up to 2 hours of general use; up to 2.5 hours of video watching; can be used while charging",
                "Connectivity": "Wi‑Fi 6 (802.11ax), Bluetooth 5.3",
                "Audio": "Spatial Audio with dynamic head tracking; six-mic array with directional beamforming",
                "Sensors": "Two high-resolution main cameras; six world-facing tracking cameras; four eye-tracking cameras; TrueDepth camera; LiDAR Scanner; four inertial measurement units (IMUs); flicker sensor; ambient light sensor",
                "Biometric Authentication": "Optic ID (iris-based biometric authentication)",
                "Input Methods": "Hands, eyes, voice; supports keyboards, trackpads, game controllers",
                "Interpupillary Distance (IPD)": "51–75 mm"
            ]
        ),
        // Add other supported devices here...
    ]
    
    var body: some View {
        NavigationView {
            List(devices) { device in
                NavigationLink(destination: DeviceDetailView(device: device)) {
                    Text(device.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Supported Devices")
        }
    }
}
