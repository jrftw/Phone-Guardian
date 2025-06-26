import Foundation
import os

class TemperatureManager {
    static let shared = TemperatureManager()
    private let logger = Logger(subsystem: "com.phoneguardian.temperaturemanager", category: "TemperatureManager")
    private var hasLoggedTemperature = false

    private init() {}

    func getDeviceTemperature() -> Int {
        let thermalState = ProcessInfo.processInfo.thermalState
        let temp: Int
        switch thermalState {
        case .nominal:
            temp = 75
        case .fair:
            temp = 85
        case .serious:
            temp = 95
        case .critical:
            temp = 105
        @unknown default:
            temp = 75
        }
        if !hasLoggedTemperature {
            logger.info("Device Temperature: \(temp)")
            hasLoggedTemperature = true
        }
        return temp
    }
}
