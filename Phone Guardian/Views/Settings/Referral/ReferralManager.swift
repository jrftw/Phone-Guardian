// ReferralManager.swift

import Foundation
import Combine

class ReferralManager: ObservableObject {
    private let referralCodeKey = "referralCode"
    private let referralCountKey = "referralCount"
    private let tempGoldExpirationKey = "tempGoldExpiration"
    private let tempToolsExpirationKey = "tempToolsExpiration"
    private let tempNoAdsExpirationKey = "tempNoAdsExpiration"

    @Published var userReferralData: UserReferralData
    private let cloudKitManager = CloudKitManager()

    init() {
        let defaults = UserDefaults.standard
        var code = defaults.string(forKey: referralCodeKey) ?? ""
        if code.isEmpty {
            code = ReferralManager.generateReferralCode()
            defaults.set(code, forKey: referralCodeKey)
            // Create a CloudKit user record for this code if not exists
            cloudKitManager.createUserIfNeeded(referralCode: code) { _, _ in }
        } else {
            // Ensure there's a user record in CloudKit for this code
            cloudKitManager.createUserIfNeeded(referralCode: code) { _, _ in }
        }
        let count = defaults.integer(forKey: referralCountKey)
        self.userReferralData = UserReferralData(referralCode: code, referralCount: count)
    }

    func loadReferralData() {
        let defaults = UserDefaults.standard
        let code = defaults.string(forKey: referralCodeKey) ?? ""
        let count = defaults.integer(forKey: referralCountKey)
        userReferralData = UserReferralData(referralCode: code, referralCount: count)
    }

    func recordReferralUsage() {
        let defaults = UserDefaults.standard
        var currentCount = defaults.integer(forKey: referralCountKey)
        currentCount += 1
        defaults.set(currentCount, forKey: referralCountKey)
        userReferralData.referralCount = currentCount

        // Update CloudKit record for this user
        cloudKitManager.fetchUserRecord(byReferralCode: userReferralData.referralCode) { record, _ in
            guard let record = record else { return }
            let currentCountCK = record["referralCount"] as? Int ?? 0
            record["referralCount"] = currentCountCK + 1
            self.cloudKitManager.incrementReferralCount(for: record) { _ in }
        }
    }

    func grantTemporaryFeature(_ feature: TemporaryFeature) {
        let defaults = UserDefaults.standard
        if let expiration = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
            switch feature {
            case .gold:
                defaults.set(expiration, forKey: tempGoldExpirationKey)
            case .tools:
                defaults.set(expiration, forKey: tempToolsExpirationKey)
            case .noAds:
                defaults.set(expiration, forKey: tempNoAdsExpirationKey)
            }
        }
    }

    func isFeatureActive(_ feature: TemporaryFeature, hasPermanent: Bool) -> Bool {
        guard !hasPermanent else { return true }
        let now = Date()
        let defaults = UserDefaults.standard
        switch feature {
        case .gold:
            if let exp = defaults.object(forKey: tempGoldExpirationKey) as? Date, now < exp {
                return true
            }
        case .tools:
            if let exp = defaults.object(forKey: tempToolsExpirationKey) as? Date, now < exp {
                return true
            }
        case .noAds:
            if let exp = defaults.object(forKey: tempNoAdsExpirationKey) as? Date, now < exp {
                return true
            }
        }
        return false
    }

    private static func generateReferralCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).compactMap { _ in characters.randomElement() })
    }

    func validateAndApplyReferral(code: String, completion: @escaping (Bool, Bool, Bool) -> Void) {
        // completion params: (isValid, isSelfReferral, didSucceed)
        // isValid: if format is correct
        // isSelfReferral: if code matches user's own code
        // didSucceed: if we successfully incremented referral count of that code's owner

        let enteredCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let isValidFormat = enteredCode.count == 8 && enteredCode.allSatisfy { $0.isNumber || $0.isUppercase }

        guard !enteredCode.isEmpty else {
            completion(false, false, false)
            return
        }
        guard enteredCode != userReferralData.referralCode else {
            completion(true, true, false)
            return
        }
        guard isValidFormat else {
            completion(false, false, false)
            return
        }

        // Fetch user with this code in CloudKit and increment their referral count
        cloudKitManager.fetchUserRecord(byReferralCode: enteredCode) { record, error in
            if let record = record, error == nil {
                // Valid referral code, increment their count
                self.cloudKitManager.incrementReferralCount(for: record) { success in
                    completion(true, false, success)
                }
            } else {
                // No user found with that code
                completion(false, false, false)
            }
        }
    }
}
