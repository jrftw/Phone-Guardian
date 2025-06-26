//
//  PermissionsManager.swift
//  Phone Guardian
//
//  Created by Kevin Doyle Jr. on 11/22/24.
//


import Foundation
import Photos
import Contacts
import EventKit

struct PermissionsManager {
    // MARK: - Photos Access
    static func requestPhotosAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }

    // MARK: - Contacts Access
    static func requestContactsAccess(completion: @escaping (Bool) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Calendar Access
    static func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}