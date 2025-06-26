// DuplicateScanner.swift

import Foundation
import Photos
import Contacts
import EventKit
import os.log
import Combine

class DuplicateScanner: ObservableObject {
    static let shared = DuplicateScanner()

    private init() {}

    // MARK: - Published Properties
    @Published var currentTask: String = ""
    @Published var progress: Double = 0.0
    @Published var isScanning: Bool = false
    @Published var duplicatesByCategory: [String: [DuplicateItem]] = [
        "Photos": [],
        "Videos": [],
        "Contacts": [],
        "Calendar": []
    ]

    private var totalTasks: Double = 4.0
    private var completedTasks: Double = 0.0

    // MARK: - Start Duplicate Scan
    func startDuplicateScan() {
        os_log("Starting duplicate scan.")
        isScanning = true
        duplicatesByCategory = ["Photos": [], "Videos": [], "Contacts": [], "Calendar": []]
        currentTask = "Initializing..."
        progress = 0.0
        completedTasks = 0.0

        let taskQueue: [(String, (@escaping () -> Void) -> Void)] = [
            ("Scanning Photos", scanPhotos),
            ("Scanning Videos", scanVideos),
            ("Scanning Contacts", scanContacts),
            ("Scanning Calendar", scanCalendar)
        ]

        let taskGroup = DispatchGroup()

        for (taskName, task) in taskQueue {
            taskGroup.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    self.currentTask = taskName
                }
                task {
                    DispatchQueue.main.async {
                        self.completedTasks += 1
                        self.progress = self.completedTasks / self.totalTasks
                        taskGroup.leave()
                    }
                }
            }
        }

        taskGroup.notify(queue: .main) {
            os_log("Duplicate scan completed with total duplicates: %d", self.totalDuplicateCount())
            self.currentTask = "Scan Complete"
            self.isScanning = false
        }
    }

    private func totalDuplicateCount() -> Int {
        return duplicatesByCategory.values.reduce(0) { $0 + $1.count }
    }

    // MARK: - Scan Photos
    private func scanPhotos(completion: @escaping () -> Void) {
        os_log("Scanning photos for duplicates.")
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                os_log("Photo library access denied.")
                completion()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                var photoHashes = [String: [PHAsset]]()

                allPhotos.enumerateObjects { asset, _, _ in
                    let key = "\(asset.pixelWidth)x\(asset.pixelHeight)-\(asset.creationDate?.timeIntervalSince1970 ?? 0)"
                    if photoHashes[key] != nil {
                        photoHashes[key]?.append(asset)
                    } else {
                        photoHashes[key] = [asset]
                    }
                }

                var duplicates = [DuplicateItem]()
                for (_, assets) in photoHashes where assets.count > 1 {
                    for asset in assets {
                        let fileName = asset.value(forKey: "filename") as? String ?? "Unknown"
                        let duplicateItem = DuplicateItem(name: fileName, detail: "Duplicate Photo", asset: asset)
                        duplicates.append(duplicateItem)
                    }
                }

                os_log("Found %d duplicate photos.", duplicates.count)
                DispatchQueue.main.async {
                    self.duplicatesByCategory["Photos"] = duplicates
                    completion()
                }
            }
        }
    }

    // MARK: - Scan Videos
    private func scanVideos(completion: @escaping () -> Void) {
        os_log("Scanning videos for duplicates.")
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                os_log("Photo library access denied.")
                completion()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                let allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var videoHashes = [String: [PHAsset]]()

                allVideos.enumerateObjects { asset, _, _ in
                    let key = "\(asset.duration)-\(asset.pixelWidth)x\(asset.pixelHeight)-\(asset.creationDate?.timeIntervalSince1970 ?? 0)"
                    if videoHashes[key] != nil {
                        videoHashes[key]?.append(asset)
                    } else {
                        videoHashes[key] = [asset]
                    }
                }

                var duplicates = [DuplicateItem]()
                for (_, assets) in videoHashes where assets.count > 1 {
                    for asset in assets {
                        let fileName = asset.value(forKey: "filename") as? String ?? "Unknown"
                        let duplicateItem = DuplicateItem(name: fileName, detail: "Duplicate Video", asset: asset)
                        duplicates.append(duplicateItem)
                    }
                }

                os_log("Found %d duplicate videos.", duplicates.count)
                DispatchQueue.main.async {
                    self.duplicatesByCategory["Videos"] = duplicates
                    completion()
                }
            }
        }
    }

    // MARK: - Scan Contacts
    private func scanContacts(completion: @escaping () -> Void) {
        os_log("Scanning contacts for duplicates.")
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, _ in
            guard granted else {
                os_log("Contacts access denied.")
                completion()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let keysToFetch = [
                        CNContactGivenNameKey,
                        CNContactFamilyNameKey,
                        CNContactEmailAddressesKey,
                        CNContactPhoneNumbersKey
                    ] as [CNKeyDescriptor]
                    let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                    var contacts = [CNContact]()
                    try contactStore.enumerateContacts(with: request) { contact, _ in
                        contacts.append(contact)
                    }

                    let contactMap = Dictionary(grouping: contacts) {
                        "\($0.givenName.lowercased()) \($0.familyName.lowercased()) \($0.emailAddresses.first?.value.lowercased ?? "") \($0.phoneNumbers.first?.value.stringValue ?? "")"
                    }

                    var duplicates = [DuplicateItem]()
                    for (_, groupedContacts) in contactMap where groupedContacts.count > 1 {
                        for contact in groupedContacts {
                            let contactName = "\(contact.givenName) \(contact.familyName)"
                            let duplicateItem = DuplicateItem(name: contactName, detail: "Duplicate Contact", contact: contact)
                            duplicates.append(duplicateItem)
                        }
                    }

                    os_log("Found %d duplicate contacts.", duplicates.count)
                    DispatchQueue.main.async {
                        self.duplicatesByCategory["Contacts"] = duplicates
                        completion()
                    }
                } catch {
                    os_log("Failed to scan Contacts: %@", error.localizedDescription)
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }

    // MARK: - Scan Calendar Events
    private func scanCalendar(completion: @escaping () -> Void) {
        os_log("Scanning calendar events for duplicates.")
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, _ in
            guard granted else {
                os_log("Calendar access denied.")
                completion()
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
                let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
                let predicate = eventStore.predicateForEvents(withStart: oneYearAgo, end: oneYearFromNow, calendars: nil)
                let events = eventStore.events(matching: predicate)
                let eventMap = Dictionary(grouping: events) {
                    let title = $0.title?.lowercased() ?? "Unknown Title"
                    let startDateString = $0.startDate != nil ? "\($0.startDate!)" : "Unknown Date"
                    return "\(title) \(startDateString)"
                }

                var duplicates = [DuplicateItem]()
                for (_, groupedEvents) in eventMap where groupedEvents.count > 1 {
                    for event in groupedEvents {
                        let eventTitle = event.title ?? "Unknown Title"
                        let duplicateItem = DuplicateItem(name: eventTitle, detail: "Duplicate Event", event: event)
                        duplicates.append(duplicateItem)
                    }
                }

                os_log("Found %d duplicate calendar events.", duplicates.count)
                DispatchQueue.main.async {
                    self.duplicatesByCategory["Calendar"] = duplicates
                    completion()
                }
            }
        }
    }
}

// MARK: - DuplicateItem Struct

struct DuplicateItem: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    var isSelected: Bool = false

    // Assets
    var asset: PHAsset?
    var contact: CNContact?
    var event: EKEvent?
}
