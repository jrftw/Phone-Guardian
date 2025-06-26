// MARK: LOG: NETWORK
import Foundation
import SwiftUI
import Network
import CoreTelephony
import os

class SignalStrengthManager: ObservableObject {
    static let shared = SignalStrengthManager()
    private let logger = Logger(subsystem: "com.phoneguardian.signalstrength", category: "SignalStrengthManager")
    
    @Published var cellularSignal: CellularSignal = CellularSignal()
    @Published var wifiSignal: WiFiSignal = WiFiSignal()
    @Published var signalHistory: [SignalDataPoint] = []
    @Published var monitoringStatus: MonitoringStatus = .stopped
    @Published var lastUpdateDate: Date?
    
    private var monitoringTimer: Timer?
    private let maxDataPoints = 100
    
    enum MonitoringStatus {
        case stopped, running, error
    }
    
    struct CellularSignal {
        var rssi: Double = 0.0
        var snr: Double = 0.0
        var dbm: Double = 0.0
        var bars: Int = 0
        var technology: String = ""
        var carrier: String = ""
        var signalQuality: SignalQuality = .unknown
        
        enum SignalQuality {
            case excellent, good, fair, poor, noSignal, unknown
        }
    }
    
    struct WiFiSignal {
        var rssi: Double = 0.0
        var snr: Double = 0.0
        var dbm: Double = 0.0
        var bars: Int = 0
        var ssid: String = ""
        var channel: Int = 0
        var frequency: Double = 0.0
        var signalQuality: SignalQuality = .unknown
        
        enum SignalQuality {
            case excellent, good, fair, poor, noSignal, unknown
        }
    }
    
    struct SignalDataPoint: Identifiable {
        let id = UUID()
        let timestamp: Date
        let cellularRSSI: Double
        let cellularSNR: Double
        let cellularDBM: Double
        let wifiRSSI: Double
        let wifiSNR: Double
        let wifiDBM: Double
    }
    
    @MainActor
    func startMonitoring() async {
        logger.info("Starting signal strength monitoring")
        monitoringStatus = .running
        
        await updateSignalInfo()
        
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.updateSignalStrength()
            }
        }
        
        logger.info("Signal strength monitoring started")
    }
    
    @MainActor
    func stopMonitoring() {
        logger.info("Stopping signal strength monitoring")
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        monitoringStatus = .stopped
    }
    
    @MainActor
    private func updateSignalInfo() async {
        logger.debug("Updating signal information")
        
        await updateCellularInfo()
        await updateWiFiInfo()
    }
    
    @MainActor
    private func updateCellularInfo() async {
        let networkInfo = CTTelephonyNetworkInfo()
        
        // Get carrier information
        var carrierName = "Unknown"
        if let carriers = networkInfo.serviceSubscriberCellularProviders?.values {
            carrierName = carriers.compactMap { $0.carrierName }.first ?? "Unknown"
        }
        
        // Get technology information
        var technology = "Unknown"
        if let radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
            technology = getTechnologyDescription(radioAccessTechnology)
        }
        
        await MainActor.run {
            self.cellularSignal.carrier = carrierName
            self.cellularSignal.technology = technology
        }
    }
    
    @MainActor
    private func updateWiFiInfo() async {
        // In a real implementation, you would use Network framework to get WiFi information
        // For now, we'll simulate WiFi data
        
        let simulatedSSID = "Home_WiFi_Network"
        let simulatedChannel = Int.random(in: 1...13)
        let simulatedFrequency = Double(simulatedChannel) * 5.0 + 2412.0 // 2.4GHz band
        
        await MainActor.run {
            self.wifiSignal.ssid = simulatedSSID
            self.wifiSignal.channel = simulatedChannel
            self.wifiSignal.frequency = simulatedFrequency
        }
    }
    
    @MainActor
    private func updateSignalStrength() async {
        logger.debug("Updating signal strength")
        
        // Simulate cellular signal data
        let cellularRSSI = Double.random(in: -120 ... -50)
        let cellularSNR = Double.random(in: 5 ... 25)
        let cellularDBM = cellularRSSI
        
        // Simulate WiFi signal data
        let wifiRSSI = Double.random(in: -80 ... -30)
        let wifiSNR = Double.random(in: 10 ... 40)
        let wifiDBM = wifiRSSI
        
        let dataPoint = SignalDataPoint(
            timestamp: Date(),
            cellularRSSI: cellularRSSI,
            cellularSNR: cellularSNR,
            cellularDBM: cellularDBM,
            wifiRSSI: wifiRSSI,
            wifiSNR: wifiSNR,
            wifiDBM: wifiDBM
        )
        
        await MainActor.run {
            // Update cellular signal
            self.cellularSignal.rssi = cellularRSSI
            self.cellularSignal.snr = cellularSNR
            self.cellularSignal.dbm = cellularDBM
            self.cellularSignal.bars = self.calculateBars(from: cellularRSSI)
            self.cellularSignal.signalQuality = self.calculateCellularQuality(cellularRSSI, cellularSNR)
            
            // Update WiFi signal
            self.wifiSignal.rssi = wifiRSSI
            self.wifiSignal.snr = wifiSNR
            self.wifiSignal.dbm = wifiDBM
            self.wifiSignal.bars = self.calculateBars(from: wifiRSSI)
            self.wifiSignal.signalQuality = self.calculateWiFiQuality(wifiRSSI, wifiSNR)
            
            // Add to history
            self.signalHistory.append(dataPoint)
            
            // Keep only the last maxDataPoints
            if self.signalHistory.count > self.maxDataPoints {
                self.signalHistory.removeFirst()
            }
            
            self.lastUpdateDate = Date()
        }
    }
    
    private func getTechnologyDescription(_ technology: String) -> String {
        switch technology {
        case CTRadioAccessTechnologyGPRS:
            return "GPRS"
        case CTRadioAccessTechnologyEdge:
            return "EDGE"
        case CTRadioAccessTechnologyWCDMA:
            return "3G"
        case CTRadioAccessTechnologyHSDPA:
            return "3G+"
        case CTRadioAccessTechnologyHSUPA:
            return "3G+"
        case CTRadioAccessTechnologyCDMA1x:
            return "CDMA"
        case CTRadioAccessTechnologyCDMAEVDORev0:
            return "CDMA EV-DO"
        case CTRadioAccessTechnologyCDMAEVDORevA:
            return "CDMA EV-DO"
        case CTRadioAccessTechnologyCDMAEVDORevB:
            return "CDMA EV-DO"
        case CTRadioAccessTechnologyeHRPD:
            return "eHRPD"
        case CTRadioAccessTechnologyLTE:
            return "4G LTE"
        default:
            return "Unknown"
        }
    }
    
    private func calculateBars(from rssi: Double) -> Int {
        if rssi >= -50 {
            return 5
        } else if rssi >= -60 {
            return 4
        } else if rssi >= -70 {
            return 3
        } else if rssi >= -80 {
            return 2
        } else if rssi >= -90 {
            return 1
        } else {
            return 0
        }
    }
    
    private func calculateCellularQuality(_ rssi: Double, _ snr: Double) -> CellularSignal.SignalQuality {
        if rssi >= -60 && snr >= 15 {
            return .excellent
        } else if rssi >= -70 && snr >= 10 {
            return .good
        } else if rssi >= -80 && snr >= 5 {
            return .fair
        } else if rssi >= -90 {
            return .poor
        } else {
            return .noSignal
        }
    }
    
    private func calculateWiFiQuality(_ rssi: Double, _ snr: Double) -> WiFiSignal.SignalQuality {
        if rssi >= -50 && snr >= 25 {
            return .excellent
        } else if rssi >= -60 && snr >= 20 {
            return .good
        } else if rssi >= -70 && snr >= 15 {
            return .fair
        } else if rssi >= -80 {
            return .poor
        } else {
            return .noSignal
        }
    }
    
    func getSignalQualityDescription(_ quality: CellularSignal.SignalQuality) -> String {
        switch quality {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .poor:
            return "Poor"
        case .noSignal:
            return "No Signal"
        case .unknown:
            return "Unknown"
        }
    }
    
    func getSignalQualityColor(_ quality: CellularSignal.SignalQuality) -> Color {
        switch quality {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .poor:
            return .red
        case .noSignal:
            return .gray
        case .unknown:
            return .gray
        }
    }
    
    func getWiFiQualityDescription(_ quality: WiFiSignal.SignalQuality) -> String {
        switch quality {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .poor:
            return "Poor"
        case .noSignal:
            return "No Signal"
        case .unknown:
            return "Unknown"
        }
    }
    
    func getWiFiQualityColor(_ quality: WiFiSignal.SignalQuality) -> Color {
        switch quality {
        case .excellent:
            return .green
        case .good:
            return .blue
        case .fair:
            return .orange
        case .poor:
            return .red
        case .noSignal:
            return .gray
        case .unknown:
            return .gray
        }
    }
    
    func getMonitoringStatusDescription() -> String {
        switch monitoringStatus {
        case .stopped:
            return "Signal monitoring stopped"
        case .running:
            return "Signal monitoring active"
        case .error:
            return "Signal monitoring error"
        }
    }
    
    func getMonitoringStatusColor() -> Color {
        switch monitoringStatus {
        case .stopped:
            return .gray
        case .running:
            return .green
        case .error:
            return .red
        }
    }
    
    func formatRSSI(_ rssi: Double) -> String {
        return String(format: "%.1f dBm", rssi)
    }
    
    func formatSNR(_ snr: Double) -> String {
        return String(format: "%.1f dB", snr)
    }
    
    func formatFrequency(_ frequency: Double) -> String {
        if frequency > 5000 {
            return String(format: "%.0f GHz", frequency / 1000)
        } else {
            return String(format: "%.0f MHz", frequency)
        }
    }
    
    func getAverageCellularRSSI() -> Double {
        guard !signalHistory.isEmpty else { return 0.0 }
        let totalRSSI = signalHistory.reduce(0.0) { $0 + $1.cellularRSSI }
        return totalRSSI / Double(signalHistory.count)
    }
    
    func getAverageWiFiRSSI() -> Double {
        guard !signalHistory.isEmpty else { return 0.0 }
        let totalRSSI = signalHistory.reduce(0.0) { $0 + $1.wifiRSSI }
        return totalRSSI / Double(signalHistory.count)
    }
    
    func getPeakCellularRSSI() -> Double {
        return signalHistory.map { $0.cellularRSSI }.max() ?? 0.0
    }
    
    func getPeakWiFiRSSI() -> Double {
        return signalHistory.map { $0.wifiRSSI }.max() ?? 0.0
    }
    
    func clearSignalHistory() {
        logger.info("Clearing signal history")
        signalHistory.removeAll()
    }
} 