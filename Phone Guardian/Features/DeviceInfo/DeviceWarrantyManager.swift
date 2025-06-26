// MARK: LOG: DEVICE
import Foundation
import UIKit
import SwiftUI
import os

class DeviceWarrantyManager: ObservableObject {
    static let shared = DeviceWarrantyManager()
    private let logger = Logger(subsystem: "com.phoneguardian.devicewarranty", category: "DeviceWarrantyManager")

    @Published var warrantyInfo: WarrantyInfo = WarrantyInfo()
    @Published var appleCareInfo: AppleCareInfo = AppleCareInfo()
    @Published var supportStatus: SupportStatus = .checking
    @Published var lastCheckDate: Date?

    enum SupportStatus {
        case checking, active, expired, unknown, error
    }

    struct WarrantyInfo {
        var isActive: Bool = false
        var expirationDate: Date?
        var daysRemaining: Int = 0
        var warrantyType: WarrantyType = .standard
        var serialNumber: String = ""
        var modelIdentifier: String = ""
        var purchaseDate: Date?

        enum WarrantyType {
            case standard, extended, none
        }
    }

    struct AppleCareInfo {
        var isActive: Bool = false
        var expirationDate: Date?
        var daysRemaining: Int = 0
        var planType: AppleCarePlan = .none
        var incidentsRemaining: Int = 0
        var coverageDetails: [String] = []

        enum AppleCarePlan {
            case none, standard, plus, theftAndLoss
        }
    }

    @MainActor
    func checkWarrantyStatus() async {
        logger.info("Checking device warranty status")
        
        self.supportStatus = .checking

        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await self.fetchDeviceInfo()
            await self.validateWarranty()
            await self.checkAppleCare()
            await self.updateSupportStatus()
        }.value

        self.lastCheckDate = Date()
        logger.info("Warranty status check completed. Status: \(String(describing: self.supportStatus))")
    }

    private func fetchDeviceInfo() async {
        logger.debug("Fetching device information")

        let modelIdentifier: String = DeviceCapabilities.getDeviceModelCode()
        let serialNumber: String = await getDeviceSerialNumber()
        let purchaseDate: Date = await simulatePurchaseDate()

        await MainActor.run {
            self.warrantyInfo.serialNumber = serialNumber
            self.warrantyInfo.modelIdentifier = modelIdentifier
            self.warrantyInfo.purchaseDate = purchaseDate
        }
    }

    private func validateWarranty() async {
        logger.debug("Validating warranty information")

        let simulatedWarranty = await simulateWarrantyData()

        await MainActor.run {
            self.warrantyInfo = simulatedWarranty
        }
    }

    private func checkAppleCare() async {
        logger.debug("Checking AppleCare coverage")

        let simulatedAppleCare = await simulateAppleCareData()

        await MainActor.run {
            self.appleCareInfo = simulatedAppleCare
        }
    }

    private func updateSupportStatus() async {
        let now = Date()
        let warrantyActive = warrantyInfo.isActive && (warrantyInfo.expirationDate ?? now) > now
        let appleCareActive = appleCareInfo.isActive && (appleCareInfo.expirationDate ?? now) > now

        if warrantyActive || appleCareActive {
            await MainActor.run {
                self.supportStatus = .active
            }
        } else if warrantyInfo.expirationDate != nil || appleCareInfo.expirationDate != nil {
            await MainActor.run {
                self.supportStatus = .expired
            }
        } else {
            await MainActor.run {
                self.supportStatus = .unknown
            }
        }
    }

    private func getDeviceSerialNumber() async -> String {
        return "DNPX123456789"
    }

    private func simulatePurchaseDate() async -> Date {
        let calendar = Calendar.current
        let now = Date()
        let randomDays = Int.random(in: 0...730)
        return calendar.date(byAdding: .day, value: -randomDays, to: now) ?? now
    }

    private func simulateWarrantyData() async -> WarrantyInfo {
        let purchaseDate = await simulatePurchaseDate()
        let calendar = Calendar.current
        let warrantyExpiration = calendar.date(byAdding: .year, value: 1, to: purchaseDate) ?? Date()
        let now = Date()
        let daysRemaining = calendar.dateComponents([.day], from: now, to: warrantyExpiration).day ?? 0

        return WarrantyInfo(
            isActive: daysRemaining > 0,
            expirationDate: warrantyExpiration,
            daysRemaining: max(0, daysRemaining),
            warrantyType: .standard,
            serialNumber: await getDeviceSerialNumber(),
            modelIdentifier: DeviceCapabilities.getDeviceModelCode(),
            purchaseDate: purchaseDate
        )
    }

    private func simulateAppleCareData() async -> AppleCareInfo {
        let purchaseDate = await simulatePurchaseDate()
        let calendar = Calendar.current
        let hasAppleCare = Bool.random()

        if hasAppleCare {
            let appleCareExpiration = calendar.date(byAdding: .year, value: 2, to: purchaseDate) ?? Date()
            let now = Date()
            let daysRemaining = calendar.dateComponents([.day], from: now, to: appleCareExpiration).day ?? 0

            return AppleCareInfo(
                isActive: daysRemaining > 0,
                expirationDate: appleCareExpiration,
                daysRemaining: max(0, daysRemaining),
                planType: .plus,
                incidentsRemaining: Int.random(in: 0...2),
                coverageDetails: [
                    "Hardware coverage",
                    "Technical support",
                    "Express replacement",
                    "Accidental damage protection"
                ]
            )
        } else {
            return AppleCareInfo(
                isActive: false,
                expirationDate: nil,
                daysRemaining: 0,
                planType: .none,
                incidentsRemaining: 0,
                coverageDetails: []
            )
        }
    }

    func getSupportStatusDescription() -> String {
        switch supportStatus {
        case .checking: return "Checking support status..."
        case .active: return "Support coverage active"
        case .expired: return "Support coverage expired"
        case .unknown: return "Unable to determine support status"
        case .error: return "Error checking support status"
        }
    }

    func getSupportStatusColor() -> Color {
        switch supportStatus {
        case .checking: return .orange
        case .active: return .green
        case .expired: return .red
        case .unknown: return .gray
        case .error: return .red
        }
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func getWarrantyTypeDescription(_ type: WarrantyInfo.WarrantyType) -> String {
        switch type {
        case .standard: return "Standard Warranty"
        case .extended: return "Extended Warranty"
        case .none: return "No Warranty"
        }
    }

    func getAppleCarePlanDescription(_ plan: AppleCareInfo.AppleCarePlan) -> String {
        switch plan {
        case .none: return "No AppleCare"
        case .standard: return "AppleCare"
        case .plus: return "AppleCare+"
        case .theftAndLoss: return "AppleCare+ with Theft and Loss"
        }
    }

    func getDaysRemainingDescription(_ days: Int) -> String {
        if days <= 0 {
            return "Expired"
        } else if days == 1 {
            return "1 day remaining"
        } else if days < 30 {
            return "\(days) days remaining"
        } else {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s") remaining"
        }
    }
}
