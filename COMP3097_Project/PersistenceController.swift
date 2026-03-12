//
//  PersistenceController.swift
//  COMP3097_Project
//
//  Created by Tech on 2026-03-12.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    init() {
            container = NSPersistentContainer(name: "COMP3097_Project")
            container.loadPersistentStores { _, error in
                if let error {
                    fatalError("Core Data failed to load: \(error.localizedDescription)")
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
}
