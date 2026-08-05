//
//  BugTrackingSystemApp.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI
import CoreData

@main
struct BugTrackingSystemApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
