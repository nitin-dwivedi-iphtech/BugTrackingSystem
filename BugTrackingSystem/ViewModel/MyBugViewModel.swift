//
//  MyBugViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 11/08/26.
//

import CoreData
import Observation

@Observable
class MyBugViewModel {
    var assignedBugs: [Bug] = []
    var reportedBugs: [Bug] = []
    var searchQuery: String = ""
    private var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchMyBugs()
    }

    var assignedCount: Int { assignedBugs.count }
    var reportedCount: Int { reportedBugs.count }

    private var currentEmployeeID: String? {
        SessionManager.shared.employee?.employee_id
    }

    func fetchMyBugs() {
        guard let context = context,
              let employeeID = currentEmployeeID else {
            assignedBugs = []
            reportedBugs = []
            return
        }

        let request = Bug.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "open_date", ascending: false)]

        do {
            let allBugs = try context.fetch(request)
            assignedBugs = allBugs.filter { $0.assigned_employee_id == employeeID }
            reportedBugs = allBugs.filter {
                $0.reporter_employee_id == employeeID ||
                $0.bug_emaployee_relation?.employee_id == employeeID
            }
        } catch {
            print("Failed to fetch my bugs: \(error)")
            assignedBugs = []
            reportedBugs = []
        }
    }

    var filteredAssignedBugs: [Bug] {
        filterBugs(assignedBugs)
    }

    var filteredReportedBugs: [Bug] {
        filterBugs(reportedBugs)
    }

    private func filterBugs(_ bugs: [Bug]) -> [Bug] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return bugs }
        return bugs.filter { bug in
            (bug.bug_details ?? "").localizedCaseInsensitiveContains(query) ||
            (bug.bug_id ?? "").localizedCaseInsensitiveContains(query) ||
            (bug.module_name ?? "").localizedCaseInsensitiveContains(query) ||
            (bug.status ?? "").localizedCaseInsensitiveContains(query) ||
            (bug.priority ?? "").localizedCaseInsensitiveContains(query)
        }
    }
}
