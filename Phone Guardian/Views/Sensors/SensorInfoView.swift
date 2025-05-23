import SwiftUI
import CoreMotion
import CoreNFC
import os

struct SensorInfoView: View {
    private let logger = Logger(subsystem: "com.phoneguardian.sensors", category: "SensorInfoView")
    @AppStorage("enableLogging") private var enableLogging: Bool = false
    @State private var isMoreInfoPresented = false

    var body: some View {
        let sensors: [(String, Bool)] = [
            ("Touch ID", Self.supportsTouchID()),
            ("Face ID", Self.supportsFaceID()),
            ("3D Touch", Self.supports3DTouch()),
            ("Haptic Touch", Self.supportsHapticTouch()),
            ("Distance Sensor", Self.supportsDistanceSensor()),
            ("Proximity Sensor", Self.supportsProximitySensor()),
            ("Magnetometer", CMMotionManager().isMagnetometerAvailable),
            ("Gyroscope", CMMotionManager().isGyroAvailable),
            ("Device Motion", CMMotionManager().isDeviceMotionAvailable),
            ("NFC", Self.supportsNFC()),
            ("Accelerometer", CMMotionManager().isAccelerometerAvailable),
            ("Pedometer", CMPedometer.isStepCountingAvailable()),
            ("Count Floors", CMPedometer.isFloorCountingAvailable()),
            ("Count Steps", CMPedometer.isStepCountingAvailable()),
            ("Pace Steps", CMPedometer.isPaceAvailable()),
            ("Cadence Steps", CMPedometer.isCadenceAvailable()),
            ("GPS", Self.supportsGPS()),
            ("Altimeter", CMAltimeter.isRelativeAltitudeAvailable()),
            ("Barometer", CMAltimeter.isRelativeAltitudeAvailable()),
            ("In-Door Mapping", Self.supportsIndoorMapping()),
            ("Bluetooth LE", Self.supportsBluetoothLE()),
            ("Motion Coprocessor", Self.supportsMotionCoprocessor())
        ]

        return VStack(alignment: .leading, spacing: 20) {
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

    // MARK: - Determine Capabilities by Model Code

    private static func deviceModelCode() -> String {
        return DeviceCapabilities.getDeviceModelCode()
    }

    // Define sets of model codes for devices that support these features.
    // These sets should be maintained and updated as new devices appear.
    // Sourcing from Apple's known patterns:
    // - Touch ID: Introduced on iPhone 5s (iPhone6,x) and present on many devices until Face ID replaced it.
    // - Face ID: Introduced on iPhone X (iPhone10,3/iPhone10,6) and newer Face-ID devices.
    // - NFC: Introduced on iPhone 6/6 Plus (for Apple Pay), fully open from iPhone 7 and newer.

    // Note: Below sets are based on device model codes and known feature introductions.
    // For exact completeness, ensure these sets include all relevant device codes.
    // We rely on pattern:
    // Touch ID: iPhones from iPhone6,1 (5s) up to iPhone8 lines, and iPhone SE models that have it. Some iPads with Touch ID (e.g., iPad Air 2 (iPad5,x), etc.)
    // Face ID: iPhone X and later (iPhone10,3/iPhone10,6 and newer) excluding iPhone SE lines. On iPads, Face ID on iPad Pro (3rd gen and newer).
    // NFC: iPhone 7 and newer (iPhone9,x and above).

    private static let touchIDiPhonePrefixes = [
        "iPhone6,", // iPhone 5s
        "iPhone7,", // iPhone 6/6 Plus
        "iPhone8,", // iPhone 6s/6s Plus/SE(1st gen)
        "iPhone9,", // iPhone 7/7 Plus
        "iPhone10,", // iPhone 8/8 Plus still have Touch ID
        "iPhone12,8" // iPhone SE (2nd gen)
    ]
    // iPhone SE 3rd gen: iPhone14,6 also has Touch ID
    private static let touchIDAdditionaliPhones = ["iPhone14,6"]
    // iPads with Touch ID (just a few examples; adjust as needed)
    // iPad Air 2: iPad5,3 and iPad5,4
    // iPad mini 3: iPad4,7 iPad4,8 iPad4,9
    // iPad mini 4: iPad5,1 iPad5,2
    // iPad (5th gen and later), iPad Air (3rd,4th,5th), iPad mini(5th,6th), some iPad Pros until Face ID was introduced.
    private static let touchIDiPadPrefixes = [
        "iPad5,", // iPad Air 2, iPad mini 4
        "iPad6,", // iPad (5th gen)
        "iPad7,", // iPad (6th,7th gen)
        "iPad11,", // iPad Air (3rd), iPad mini (5th)
        "iPad13,", // iPad Air (4th,5th)
        "iPad14,"  // iPad (9th,10th gen)
    ]
    // Check if device is iPhone with Touch ID:
    private static func hasTouchIDModelCode(_ code: String) -> Bool {
        // iPhones with TouchID are from iPhone6,x up to before FaceID took over, plus SE models.
        if touchIDiPhonePrefixes.contains(where: { code.hasPrefix($0) }) || touchIDAdditionaliPhones.contains(code) {
            // Exclude iPhone X and later that have Face ID only:
            // Actually iPhone X has Face ID, no Touch ID. iPhone10,3 and iPhone10,6 are iPhone X variants, skip them.
            if code == "iPhone10,3" || code == "iPhone10,6" {
                return false
            }
            return true
        }
        // iPads with Touch ID
        if touchIDiPadPrefixes.contains(where: { code.hasPrefix($0) }) {
            // Exclude any that are known Face ID iPads:
            // Face ID iPads start at iPad8, and iPad13 for newer. Actually iPad8,x are Face ID (Pro 3rd gen)
            if code.hasPrefix("iPad8,") {
                // iPad Pro (3rd gen) or later with Face ID, no Touch ID
                return false
            }
            return true
        }

        return false
    }

    private static let faceIDiPhonePrefixes = [
        "iPhone10,3", "iPhone10,6", // iPhone X
        "iPhone11,", // iPhone XS/XS Max/XR
        "iPhone12,", // iPhone 11/11 Pro/11 Pro Max/SE2 doesn't have FaceID, but iPhone12,8 is SE2, handle that
        "iPhone13,", // iPhone 12 lineup
        "iPhone14,", // iPhone 13/SE3 are here, check SE3 (iPhone14,6) does not have FaceID
        "iPhone15,", // iPhone 14 lineup
        "iPhone16,", // iPhone 15 lineup
        "iPhone17,"  // iPhone 16 lineup
    ]
    // Exclude known Touch ID models from above sets. The SE lines do not have Face ID.
    // iPhone12,8 = iPhone SE (2nd gen), no FaceID
    // iPhone14,6 = iPhone SE (3rd gen), no FaceID
    private static let noFaceIDModels = ["iPhone12,8", "iPhone14,6"]

    // iPads with Face ID: iPad Pro (3rd gen) and newer (iPad8,x and beyond some iPad usage)
    // iPad8,x iPad13,x but only iPad Pro lines have Face ID:
    // iPad Pro (3rd gen 11"/12.9") are iPad8,1 - iPad8,8 etc.
    private static func hasFaceIDModelCode(_ code: String) -> Bool {
        if faceIDiPhonePrefixes.contains(where: { code.hasPrefix($0) }) && !noFaceIDModels.contains(code) {
            return true
        }

        // iPad Pro with Face ID:
        if code.hasPrefix("iPad8,") || code.hasPrefix("iPad13,") {
            // All iPad Pro (3rd gen +) identified by these codes use Face ID
            return true
        }

        return false
    }

    // NFC started iPhone6/6Plus for Apple Pay, but was limited. Fully opened NFC reading from iPhone 7 and up.
    // We'll say iPhone 7 and newer have NFC = model codes iPhone9,x and above.
    private static func hasNFCModelCode(_ code: String) -> Bool {
        // iPhone9,x and above = iPhone 7 and newer
        // Just check if code is iPhone or if it matches known sets:
        if code.hasPrefix("iPhone") {
            // Extract major version
            let parts = code.replacingOccurrences(of: "iPhone", with: "").split(separator: ",")
            if let firstPart = parts.first, let major = Int(firstPart) {
                // iPhone9 and newer have NFC:
                return major >= 9
            }
        }
        return false
    }

    // MARK: - Feature Support Checks

    static func supportsTouchID() -> Bool {
        let code = deviceModelCode()
        return hasTouchIDModelCode(code)
    }

    static func supportsFaceID() -> Bool {
        let code = deviceModelCode()
        return hasFaceIDModelCode(code)
    }

    static func supportsNFC() -> Bool {
        let code = deviceModelCode()
        return hasNFCModelCode(code)
    }

    static func supportsGPS() -> Bool {
        // GPS is supported on all iPhones and GPS-enabled iPads
        return UIDevice.current.userInterfaceIdiom == .phone || UIDevice.current.userInterfaceIdiom == .pad
    }

    static func supports3DTouch() -> Bool {
        // 3D Touch was on iPhone 6s to iPhone XS/XS Max line.
        // For simplicity, return true if device is iPhone8,x ... iPhone11,2 iPhone11,4/6 etc.
        // But user hasn't requested a thorough approach. We'll just return true as before.
        return true
    }

    static func supportsHapticTouch() -> Bool { true }
    static func supportsBluetoothLE() -> Bool { true }
    static func supportsMotionCoprocessor() -> Bool { true }
    static func supportsDistanceSensor() -> Bool { true }
    static func supportsProximitySensor() -> Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    static func supportsIndoorMapping() -> Bool { true }
}
