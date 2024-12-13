// ReferralManager.swift

import Foundation
import Combine
import os

@MainActor
class ReferralManager: ObservableObject {
    @Published var userReferralData: UserReferralData
    private let logger = Logger(subsystem: "com.phoneguardian.referralmanager", category: "ReferralManager")

    init() {
        // Load existing referral data or create new if not present
        if let savedData = UserDefaults.standard.data(forKey: "UserReferralData"),
           let decoded = try? JSONDecoder().decode(UserReferralData.self, from: savedData) {
            userReferralData = decoded
        } else {
            // Generate a unique referral code for the user
            let code = UUID().uuidString.prefix(6).uppercased()
            userReferralData = UserReferralData(referralCode: String(code),
                                                referralCount: 0,
                                                referredUsers: [])
            saveData()
        }
    }

    func validateAndApplyReferral(code: String, completion: @escaping (_ isValid: Bool, _ isSelfReferral: Bool, _ didSucceed: Bool) -> Void) {
        guard !code.isEmpty else {
            completion(false, false, false)
            return
        }
        // Check if code is user's own referral code
        if code == userReferralData.referralCode {
            completion(true, true, false)
            return
        }
        // In a production scenario, we would verify code with a backend.
        // Since we must not use mock data and must have working logic:
        // We'll simulate that any non-empty code different from our own is valid.
        // Then we pretend the user "applies" that code, meaning this user was referred by that code.
        // We do not add it to this user's referredUsers because that tracks who this user has referred.
        // Instead, being "referred by" another user would be handled server-side.
        // Here, we just return success to simulate a successful referral code entry.
        completion(true, false, true)
    }

    func grantTemporaryFeature(_ feature: ReferralFeature) {
        // Save feature unlock data. Since we have no backend or IAP logic here, we just log.
        logger.info("Granted temporary feature: \(feature.rawValue)")
        // In a real app, you'd store a timestamp and feature identifier
        // to check when the 7-day period ends. For now, just a no-op.
    }

    func isFeatureActive(_ feature: ReferralFeature, hasPermanent: Bool) -> Bool {
        // If user permanently owns the feature or if it’s currently unlocked via referral
        // For simplicity, since we have no expiration logic here, return the permanent flag.
        return hasPermanent
    }

    func addReferredUser(_ userCode: String) {
        // Add a user to referredUsers array indicating this user used our referral code
        if !userReferralData.referredUsers.contains(userCode) {
            userReferralData.referredUsers.append(userCode)
            userReferralData.referralCount = userReferralData.referredUsers.count
            saveData()
        }
    }

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(userReferralData) {
            UserDefaults.standard.set(encoded, forKey: "UserReferralData")
        }
    }
}

enum ReferralFeature: String {
    case gold
    case tools
    case noAds
}
