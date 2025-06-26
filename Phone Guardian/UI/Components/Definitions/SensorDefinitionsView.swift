import SwiftUI

struct SensorDefinitionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Definitions")
                    .font(.headline)

                DefinitionRow(term: "Touch ID", definition: "A fingerprint sensor technology for biometric authentication.")
                DefinitionRow(term: "Face ID", definition: "A facial recognition system for authentication.")
                DefinitionRow(term: "3D Touch", definition: "A technology enabling pressure-sensitive touch gestures.")
                DefinitionRow(term: "Haptic Touch", definition: "A technology providing touch feedback through haptic vibration.")
                DefinitionRow(term: "Distance Sensor", definition: "A sensor used to measure distance to nearby objects.")
                DefinitionRow(term: "Proximity Sensor", definition: "Detects when a user’s face is near the device.")
                DefinitionRow(term: "Magnetometer", definition: "Measures magnetic fields, commonly used in compasses.")
                DefinitionRow(term: "Gyroscope", definition: "Measures angular rotation of the device.")
                DefinitionRow(term: "Device Motion", definition: "Combines accelerometer, gyroscope, and magnetometer data.")
                DefinitionRow(term: "NFC", definition: "Near Field Communication for short-range wireless communication.")
                DefinitionRow(term: "Accelerometer", definition: "Measures acceleration and orientation of the device.")
                DefinitionRow(term: "Pedometer", definition: "Counts steps and tracks walking distance.")
                DefinitionRow(term: "Count Floors", definition: "Tracks floors climbed using barometric pressure.")
                DefinitionRow(term: "Count Steps", definition: "Counts the total number of steps taken.")
                DefinitionRow(term: "Pace Steps", definition: "Measures steps per second.")
                DefinitionRow(term: "Cadence Steps", definition: "Measures walking/running rhythm in steps per second.")
                DefinitionRow(term: "GPS", definition: "Provides location and navigation using satellites.")
                DefinitionRow(term: "Altimeter", definition: "Measures altitude changes using barometric pressure.")
                DefinitionRow(term: "Barometer", definition: "Measures atmospheric pressure.")
                DefinitionRow(term: "In-Door Mapping", definition: "Provides navigation in indoor environments.")
                DefinitionRow(term: "Bluetooth LE", definition: "Low-energy Bluetooth for wireless connectivity.")
                DefinitionRow(term: "Motion Coprocessor", definition: "Processes motion-related data efficiently.")
            }
            .padding()
        }
    }
}
