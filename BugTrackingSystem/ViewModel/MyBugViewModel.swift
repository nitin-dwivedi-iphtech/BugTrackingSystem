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
    var allBugs: [Bug] = []
    var assignedBugs: [Bug] = []
    var reportedBugs: [Bug] = []
    var recentlyUpdatedBugs: [Bug] = []
    var searchQuery: String = ""
    private var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchMyBugs()
    }

    var assignedCount: Int { assignedBugs.count }
    var reportedCount: Int { reportedBugs.count }
    var recentlyUpdatedCount: Int { recentlyUpdatedBugs.count }

    private var currentEmployeeID: String? {
        SessionManager.shared.employee?.employee_id
    }

    func fetchMyBugs() {
        guard let context = context,
              let employeeID = currentEmployeeID else {
            allBugs = []
            assignedBugs = []
            reportedBugs = []
            recentlyUpdatedBugs = []
            return
        }

        let teamBugs = teamBugs(in: context)
        allBugs = teamBugs.sorted { ($0.open_date ?? .distantPast) > ($1.open_date ?? .distantPast) }
        assignedBugs = allBugs.filter { $0.assigned_employee_id == employeeID }
        reportedBugs = allBugs.filter {
            $0.reporter_employee_id == employeeID ||
            $0.bug_emaployee_relation?.employee_id == employeeID
        }
        recentlyUpdatedBugs = teamBugs
            .sorted { ($0.updated_date ?? .distantPast) > ($1.updated_date ?? .distantPast) }
    }

    var favoriteBugs: [Bug] {
        let ids = favoriteBugIDs
        return filterBugs(allBugs.filter { $0.bug_id != nil && ids.contains($0.bug_id!) })
    }

    private var favoriteBugIDs: Set<String> {
        let raw = SessionManager.shared.employee?.favourite_bug_id ?? ""
        return Set(raw.split(separator: ",").map(String.init))
    }

    private func teamBugs(in context: NSManagedObjectContext) -> [Bug] {
        guard let employee = SessionManager.shared.employee,
              let projects = employee.employee_team_relation?.team_project_relation?.allObjects as? [Project],
              !projects.isEmpty else { return [] }
        let projectIDs = projects.compactMap(\.project_id)
        let request = Bug.fetchRequest()
        request.predicate = NSPredicate(format: "project_id IN %@", projectIDs)
        return (try? context.fetch(request)) ?? []
    }

    var filteredAssignedBugs: [Bug] {
        filterBugs(assignedBugs)
    }

    var filteredReportedBugs: [Bug] {
        filterBugs(reportedBugs)
    }

    var filteredRecentlyUpdatedBugs: [Bug] {
        filterBugs(recentlyUpdatedBugs)
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
