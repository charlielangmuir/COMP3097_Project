//
//  COMP3097_ProjectApp.swift
//  COMP3097_Project
//
//  Created by Tech on 2026-03-12.
//

import SwiftUI
import CoreData

@main
struct COMP3097_ProjectApp: App {
    let persistence = PersistenceController.shared
    var body: some Scene {
            WindowGroup {
                RootView().environment(\.managedObjectContext, persistence.container.viewContext)
            }
        }
}
