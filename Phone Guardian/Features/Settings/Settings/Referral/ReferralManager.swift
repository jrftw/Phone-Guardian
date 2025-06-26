// ReferralManager.swift

import Foundation
import Combine
import os

enum ReferralFeature: String {
    case gold
    case tools
    case noAds
}

@MainActor
class ReferralManager: ObservableObject {
    @Published var userReferralData: UserReferralData
    private let logger = Logger(subsystem: "com.phoneguardian.referralmanager", category: "ReferralManager")

    init() {
        if let savedData = UserDefaults.standard.data(forKey: "UserReferralData"),
           let decoded = try? JSONDecoder().decode(UserReferralData.self, from: savedData) {
            userReferralData = decoded
        } else {
            let code = UUID().uuidString.prefix(6).uppercased()
            userReferralData = UserReferralData(referralCode: String(code), referralCount: 0, referredUsers: [])
            saveData()
        }
    }

    func validateAndApplyReferral(code: String, completion: @escaping (Bool, Bool, Bool) -> Void) {
        guard !code.isEmpty else {
            completion(false, false, false)
            return
        }
        if code == userReferralData.referralCode {
            completion(true, true, false)
            return
        }
        completion(true, false, true)
    }

    func grantTemporaryFeature(_ feature: ReferralFeature) {
        logger.info("Granted temporary feature: \(feature.rawValue)")
    }

    func isFeatureActive(_ feature: ReferralFeature, hasPermanent: Bool) -> Bool {
        return hasPermanent
    }

    func addReferredUser(_ userCode: String) {
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
