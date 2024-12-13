// UserReferralData.swift

import Foundation

struct UserReferralData: Codable, Hashable {
    var referralCode: String
    var referralCount: Int
    var referredUsers: [String]
}
