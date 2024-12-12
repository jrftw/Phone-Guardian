//
//  CloudKitManager.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 12/12/24.
//


// CloudKitManager.swift

import CloudKit

class CloudKitManager {
    private let container = CKContainer.default()
    private let database = CKContainer.default().publicCloudDatabase
    private let userRecordType = "User"

    func fetchUserRecord(byReferralCode code: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(format: "referralCode == %@", code)
        let query = CKQuery(recordType: userRecordType, predicate: predicate)
        database.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil, !records.isEmpty else {
                completion(nil, error)
                return
            }
            completion(records.first, nil)
        }
    }

    func incrementReferralCount(for record: CKRecord, completion: @escaping (Bool) -> Void) {
        let currentCount = record["referralCount"] as? Int ?? 0
        record["referralCount"] = currentCount + 1
        database.save(record) { _, error in
            completion(error == nil)
        }
    }

    func createUserIfNeeded(referralCode: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        fetchUserRecord(byReferralCode: referralCode) { record, error in
            if let record = record {
                completion(record, nil)
            } else {
                let userRecord = CKRecord(recordType: self.userRecordType)
                userRecord["referralCode"] = referralCode
                userRecord["referralCount"] = 0
                self.database.save(userRecord) { savedRecord, saveError in
                    completion(savedRecord, saveError)
                }
            }
        }
    }
}