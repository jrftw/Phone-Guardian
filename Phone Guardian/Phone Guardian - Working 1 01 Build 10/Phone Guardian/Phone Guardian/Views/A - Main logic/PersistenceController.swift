import CoreData
import os

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhoneGuardianModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                Logger(subsystem: "com.phoneguardian.persistence", category: "Error")
                    .error("Unresolved error: \(error), \(error.userInfo)")
            }
        }
    }
}
