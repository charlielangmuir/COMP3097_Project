//
//  PersistenceController.swift
//  COMP3097_Project
//
//  Created by Tech on 2026-03-12.
//

import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "COMP3097_Project")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func fetchCustomGroups() throws -> [StoredShoppingGroup] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Group")
        request.predicate = NSPredicate(format: "isCustom == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        return try viewContext.fetch(request).compactMap { object in
            mapGroup(object)
        }
    }

    @discardableResult
    func saveCustomGroup(name: String, isTaxable: Bool) throws -> StoredShoppingGroup {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let id = UUID()
        let object = NSEntityDescription.insertNewObject(forEntityName: "Group", into: viewContext)

        object.setValue(id, forKey: "id")
        object.setValue(trimmedName, forKey: "name")
        object.setValue(trimmedName, forKey: "apiCategory")
        object.setValue(true, forKey: "isCustom")
        object.setValue(isTaxable, forKey: "isTaxable")

        try saveContext()

        return StoredShoppingGroup(
            id: id,
            name: trimmedName,
            apiCategory: trimmedName,
            isCustom: true,
            isTaxable: isTaxable
        )
    }

    func fetchItems(for group: StoredShoppingGroup) throws -> [StoredShoppingItem] {
        guard let groupObject = try fetchGroupObject(for: group) else {
            return []
        }

        let request = NSFetchRequest<NSManagedObject>(entityName: "ShoppingItem")
        request.predicate = NSPredicate(format: "group == %@", groupObject)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        return try viewContext.fetch(request).compactMap { object in
            mapItem(object)
        }
    }

    func replaceItems(_ items: [StoredShoppingItem], for group: StoredShoppingGroup) throws {
        let groupObject = try fetchOrCreateGroupObject(for: group)
        let existingItems = try fetchItemObjects(for: groupObject)

        for object in existingItems {
            viewContext.delete(object)
        }

        for item in items {
            let object = NSEntityDescription.insertNewObject(forEntityName: "ShoppingItem", into: viewContext)
            object.setValue(item.id, forKey: "id")
            object.setValue(Int32(item.remoteID ?? 0), forKey: "remoteID")
            object.setValue(item.name, forKey: "name")
            object.setValue(item.price, forKey: "price")
            object.setValue(Int16(item.quantity), forKey: "quantity")
            object.setValue(item.purchased, forKey: "purchased")
            object.setValue(item.category, forKey: "category")
            object.setValue(item.details, forKey: "details")
            object.setValue(item.imageURL, forKey: "imageURL")
            object.setValue(groupObject, forKey: "group")
        }

        try saveContext()
    }

    private func fetchOrCreateGroupObject(for group: StoredShoppingGroup) throws -> NSManagedObject {
        if let existing = try fetchGroupObject(for: group) {
            existing.setValue(group.name, forKey: "name")
            existing.setValue(group.apiCategory, forKey: "apiCategory")
            existing.setValue(group.isCustom, forKey: "isCustom")
            existing.setValue(group.isTaxable, forKey: "isTaxable")
            return existing
        }

        let object = NSEntityDescription.insertNewObject(forEntityName: "Group", into: viewContext)
        object.setValue(group.id, forKey: "id")
        object.setValue(group.name, forKey: "name")
        object.setValue(group.apiCategory, forKey: "apiCategory")
        object.setValue(group.isCustom, forKey: "isCustom")
        object.setValue(group.isTaxable, forKey: "isTaxable")
        return object
    }

    private func fetchGroupObject(for group: StoredShoppingGroup) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Group")
        request.fetchLimit = 1

        if group.isCustom {
            request.predicate = NSPredicate(format: "id == %@", group.id as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "apiCategory == %@ AND isCustom == NO", group.apiCategory)
        }

        return try viewContext.fetch(request).first
    }

    private func fetchItemObjects(for groupObject: NSManagedObject) throws -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ShoppingItem")
        request.predicate = NSPredicate(format: "group == %@", groupObject)
        return try viewContext.fetch(request)
    }

    private func mapGroup(_ object: NSManagedObject) -> StoredShoppingGroup? {
        guard
            let id = object.value(forKey: "id") as? UUID,
            let name = object.value(forKey: "name") as? String,
            let apiCategory = object.value(forKey: "apiCategory") as? String
        else {
            return nil
        }

        return StoredShoppingGroup(
            id: id,
            name: name,
            apiCategory: apiCategory,
            isCustom: object.value(forKey: "isCustom") as? Bool ?? false,
            isTaxable: object.value(forKey: "isTaxable") as? Bool ?? true
        )
    }

    private func mapItem(_ object: NSManagedObject) -> StoredShoppingItem? {
        guard
            let id = object.value(forKey: "id") as? UUID,
            let name = object.value(forKey: "name") as? String
        else {
            return nil
        }

        let storedRemoteID = object.value(forKey: "remoteID") as? Int32 ?? 0

        return StoredShoppingItem(
            id: id,
            remoteID: storedRemoteID == 0 ? nil : Int(storedRemoteID),
            name: name,
            price: object.value(forKey: "price") as? Double ?? 0,
            quantity: Int(object.value(forKey: "quantity") as? Int16 ?? 1),
            purchased: object.value(forKey: "purchased") as? Bool ?? false,
            category: object.value(forKey: "category") as? String ?? "",
            details: object.value(forKey: "details") as? String ?? "",
            imageURL: object.value(forKey: "imageURL") as? String ?? ""
        )
    }

    func saveContext() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}
