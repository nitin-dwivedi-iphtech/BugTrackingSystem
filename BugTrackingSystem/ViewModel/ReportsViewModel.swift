//
//  ReportsViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import CoreData
import Observation

@Observable
class ReportsViewModel {
    var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func bugCount(for project: Project) -> Int {
        guard let context = context, let projectID = project.project_id else { return 0 }
        let request = Bug.fetchRequest()
        request.predicate = NSPredicate(format: "project_id == %@", projectID)
        return (try? context.count(for: request)) ?? 0
    }
}
