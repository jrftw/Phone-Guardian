import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    @NSManaged public var timestamp: Date
}

extension Item {
    static func fetchAllItems(context: NSManagedObjectContext) -> [Item] {
        let request: NSFetchRequest<Item> = Item.fetchRequest() as! NSFetchRequest<Item>
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch items: \(error.localizedDescription)")
            return []
        }
    }

    static func createItem(context: NSManagedObjectContext) {
        let newItem = Item(context: context)
        newItem.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            print("Failed to save new item: \(error.localizedDescription)")
        }
    }
}

extension Item: Identifiable { }
