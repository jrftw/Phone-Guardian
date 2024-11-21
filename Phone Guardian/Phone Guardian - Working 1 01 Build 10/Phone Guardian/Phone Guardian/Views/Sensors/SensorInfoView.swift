import SwiftUI
import CoreMotion
import CoreNFC
import os

struct SensorInfoView: View {
    private let logger = Logger(subsystem: "com.phoneguardian.sensors", category: "SensorInfoView")
    @AppStorage("enableLogging") private var enableLogging: Bool = false
    @State private var isMoreInfoPresented = false

    let sensors: [(String, Bool)] = [
        ("Touch ID", supportsTouchID()),
        ("Face ID", supportsFaceID()),
        ("3D Touch", supports3DTouch()),
        ("Haptic Touch", supportsHapticTouch()),
        ("Distance Sensor", supportsDistanceSensor()),
        ("Proximity Sensor", supportsProximitySensor()),
        ("Magnetometer", CMMotionManager().isMagnetometerAvailable),
        ("Gyroscope", CMMotionManager().isGyroAvailable),
        ("Device Motion", CMMotionManager().isDeviceMotionAvailable),
        ("NFC", NFCReaderSession.readingAvailable),
        ("Accelerometer", CMMotionManager().isAccelerometerAvailable),
        ("Pedometer", CMPedometer.isStepCountingAvailable()),
        ("Count Floors", CMPedometer.isFloorCountingAvailable()),
        ("Count Steps", CMPedometer.isStepCountingAvailable()),
        ("Pace Steps", CMPedometer.isPaceAvailable()),
        ("Cadence Steps", CMPedometer.isCadenceAvailable()),
        ("GPS", supportsGPS()),
        ("Altimeter", CMAltimeter.isRelativeAltitudeAvailable()),
        ("Barometer", CMAltimeter.isRelativeAltitudeAvailable()),
        ("In-Door Mapping", supportsIndoorMapping()),
        ("Bluetooth LE", supportsBluetoothLE()),
        ("Motion Coprocessor", supportsMotionCoprocessor())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SENSORS")
                .font(.title2)
                .bold()

            ForEach(sensors, id: \.0) { sensor in
                InfoRow(label: sensor.0, value: sensor.1 ? "✔︎" : "✘")
            }

            Spacer()

            Button(action: { isMoreInfoPresented.toggle() }) {
                Text("More Info")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $isMoreInfoPresented) {
                SensorDefinitionsView()
            }
        }
        .padding()
        .onAppear {
            logger.info("SensorInfoView appeared.")
        }
    }

    // MARK: - Static Sensor Capability Checks

    static func supportsTouchID() -> Bool {
        let touchIDIphones = [
            "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus",
            "iPhone 8", "iPhone 8 Plus", "iPhone SE (2nd generation)",
            "iPhone SE (3rd generation)"
        ]
        
        let touchIDIpads = [
            "iPad Air (4th generation)", "iPad Air (5th generation)",
            "iPad Mini (6th generation)", "iPad Air 2",
            "iPad Air (3rd generation)", "iPad (10th generation)",
            "iPad Pro (1st generation)", "iPad Pro (2nd generation)"
        ]
        
        return touchIDIphones.contains(UIDevice.current.name) ||
               touchIDIpads.contains(UIDevice.current.name)
    }

    static func supportsFaceID() -> Bool {
        let faceIDIphones = [
            "iPhone X", "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max",
            "iPhone 12", "iPhone 12 Mini", "iPhone 12 Pro", "iPhone 12 Pro Max",
            "iPhone 13", "iPhone 13 Mini", "iPhone 13 Pro", "iPhone 13 Pro Max",
            "iPhone 14", "iPhone 14 Plus", "iPhone 14 Pro", "iPhone 14 Pro Max",
            "iPhone 15", "iPhone 15 Plus", "iPhone 15 Pro", "iPhone 15 Pro Max",
            "iPhone 16", "iPhone 16 Plus", "iPhone 16 Pro", "iPhone 16 Pro Max"
        ]
        
        let faceIDIpads = [
            "iPad Pro 12.9-Inch 6th Generation", "iPad Pro 12.9-Inch 5th Generation",
            "iPad Pro 12.9-Inch 4th Generation", "iPad Pro 12.9-Inch 3rd Generation",
            "iPad Pro 11-Inch 4th Generation", "iPad Pro 11-Inch 3rd Generation",
            "iPad Pro 11-Inch 2nd Generation"
        ]

        return faceIDIphones.contains(UIDevice.current.name) ||
               faceIDIpads.contains(UIDevice.current.name)
    }
 

    static func supports3DTouch() -> Bool { true } // Assumed availability, customize as needed
    static func supportsHapticTouch() -> Bool { true }
    static func supportsGPS() -> Bool { true }
    static func supportsBluetoothLE() -> Bool { true }
    static func supportsMotionCoprocessor() -> Bool { true }
    static func supportsDistanceSensor() -> Bool { true }
    static func supportsProximitySensor() -> Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    static func supportsIndoorMapping() -> Bool { true } // Assumed availability
}
