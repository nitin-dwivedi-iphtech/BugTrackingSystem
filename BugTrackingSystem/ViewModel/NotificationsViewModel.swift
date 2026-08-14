//
//  NotificationsViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import CoreData
import Observation

@Observable
class NotificationsViewModel {
    var items: [NotificationItem] = []
    private var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchNotifications()
    }

    var totalCount: Int { items.count }

    func items(of type: NotificationType) -> [NotificationItem] {
        items
            .filter { $0.type == type }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var currentEmployeeID: String? {
        SessionManager.shared.employee?.employee_id
    }

    func fetchNotifications() {
        guard let context = context,
              let employeeID = currentEmployeeID else {
            items = []
            return
        }

        let allBugs = teamBugs(in: context)
        var built: [NotificationItem] = []

        for bug in allBugs where bug.assigned_employee_id == employeeID {
            built.append(NotificationItem(
                id: UUID(),
                type: .assigned,
                message: "\"\(bug.bug_details ?? "Untitled Bug")\" was assigned to you",
                timestamp: bug.open_date ?? Date(),
                bug: bug
            ))
        }

        let teamBugIDs = Array(allBugs.compactMap(\.bug_id))
        if !teamBugIDs.isEmpty {
            let commentRequest = Comment.fetchRequest()
            commentRequest.predicate = NSPredicate(format: "bug_id IN %@", teamBugIDs)
            commentRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if let comments = try? context.fetch(commentRequest) {
                for comment in comments where comment.employee_id != employeeID {
                    guard let bug = allBugs.first(where: { $0.bug_id == comment.bug_id }) else { continue }
                    let name = comment.comment_employee_relation?.employee_name ?? "Someone"
                    built.append(NotificationItem(
                        id: UUID(),
                        type: .comment,
                        message: "\(name) commented on \"\(bug.bug_details ?? "Untitled Bug")\"",
                        timestamp: comment.timestamp ?? Date(),
                        bug: bug
                    ))
                }
            }
        }

        for bug in allBugs
            where bug.status != nil && bug.status != BugStatus.open.rawValue {
            built.append(NotificationItem(
                id: UUID(),
                type: .statusUpdated,
                message: "\"\(bug.bug_details ?? "Untitled Bug")\" is now \(bug.status ?? "Open")",
                timestamp: bug.status_updated_date ?? bug.open_date ?? Date(),
                bug: bug
            ))
        }

        for bug in allBugs
            where bug.priority == BugPriority.high.rawValue || bug.priority == BugPriority.critical.rawValue {
            built.append(NotificationItem(
                id: UUID(),
                type: .priorityChanged,
                message: "\"\(bug.bug_details ?? "Untitled Bug")\" was prioritized as \(bug.priority ?? "High")",
                timestamp: bug.updated_date ?? bug.open_date ?? Date(),
                bug: bug
            ))
        }

        items = built
    }

    private func teamBugs(in context: NSManagedObjectContext) -> [Bug] {
        guard let employee = SessionManager.shared.employee,
              let projects = employee.employee_team_relation?.team_project_relation?.allObjects as? [Project],
              !projects.isEmpty else { return [] }
        let projectIDs = projects.compactMap(\.project_id)
        let request = Bug.fetchRequest()
        request.predicate = NSPredicate(format: "project_id IN %@", projectIDs)
        request.sortDescriptors = [NSSortDescriptor(key: "open_date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
}
