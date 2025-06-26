// CloudKitManager.swift

import CloudKit

class CloudKitManager {
    private let container = CKContainer.default()
    private let database = CKContainer.default().publicCloudDatabase
    private let userRecordType = "User"

    func fetchUserRecord(byReferralCode code: String, completion: @escaping (CKRecord?, Error?) -> Void) {
        let predicate = NSPredicate(format: "referralCode == %@", code)
        let query = CKQuery(recordType: userRecordType, predicate: predicate)
        
        if #available(iOS 15.0, *) {
            database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 1) { (result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) in
                switch result {
                case .success(let (matchResults, _)):
                    if let recordResult = matchResults.first?.1 {
                        switch recordResult {
                        case .success(let record):
                            completion(record, nil)
                        case .failure(let error):
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, nil)
                    }
                case .failure(let error):
                    completion(nil, error)
                }
            }
        } else {
            database.perform(query, inZoneWith: nil) { records, error in
                guard let records = records, error == nil, !records.isEmpty else {
                    completion(nil, error)
                    return
                }
                completion(records.first, nil)
            }
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
