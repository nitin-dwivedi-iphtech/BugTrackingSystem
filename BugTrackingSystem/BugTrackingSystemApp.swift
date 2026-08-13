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
    @AppStorage("darkMode") private var darkMode = false

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(darkMode ? .dark : .light)
        }
    }
}
