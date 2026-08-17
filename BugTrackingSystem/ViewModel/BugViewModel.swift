//
//  BugViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import CoreData

@Observable
class BugViewModel {
    var isQaTester:Bool { SessionManager.shared.isQaTester }
    var isDev:Bool { SessionManager.shared.isDeveloper }
    var isProjectManager:Bool { SessionManager.shared.isProjectManager }

    func canEditBug(_ bug: Bug) -> Bool {
        if isProjectManager { return true }
        guard isQaTester,
              let myID = employee?.employee_id else { return false }
        return bug.reporter_employee_id == myID ||
               bug.bug_emaployee_relation?.employee_id == myID
    }
    var developers: [Employee] {
        let all = (employee?.employee_team_relation?.team_employee_relation?.allObjects as? [Employee]) ?? []
        return all.filter { $0.role == RoleEnum.developer.rawValue }
    }
    var allBugs:[Bug] = []
    var employee:Employee? { SessionManager.shared.employee }
    var idCounter = 0
    var recentBugsToken: Int = 0
    
    var context:NSManagedObjectContext?
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchBugs()
    }
    
    func fetchBugs() {
        idCounter += 1
        guard let projects = employee?.employee_team_relation?.team_project_relation?.allObjects as? [Project],
              !projects.isEmpty else {
            allBugs = []
            return
        }

        let projectIDs = projects.compactMap(\.project_id)
        let bugRequest = Bug.fetchRequest()
        bugRequest.predicate = NSPredicate(format: "project_id IN %@", projectIDs)
        bugRequest.sortDescriptors = [NSSortDescriptor(key: "open_date", ascending: false)]

        do {
            allBugs = try context?.fetch(bugRequest) ?? []
        } catch {
            print("Failed to fetch bugs: \(error)")
            allBugs = []
        }
    }
    
    func createBug(bugTitle: String, moduleName: String, bugDescription: String, stepsToReproduce: String, expectedResult: String, actualResult: String, environment: String, priority: String, severity: String, status: String, deviceName: String, osVersion: String, appVersion: String, dueDate: Date, screenshot: Data? = nil, assignedTo: String? = nil, projectID: String? = nil, attachments: [BugAttachmentDraft] = []) {
        guard let context = self.context else { return }

        let project: Project?
        if let projectID = projectID {
            let request = Project.fetchRequest()
            request.predicate = NSPredicate(format: "project_id == %@", projectID)
            request.fetchLimit = 1
            project = try? context.fetch(request).first
        } else {
            project = employee?.employee_team_relation?.team_project_relation?.allObjects.first as? Project
        }
        guard let project = project else { return }

        let bug = Bug(context: context)
        bug.bug_id = UUID().uuidString
        bug.bug_details = bugTitle
        bug.module_name = moduleName
        bug.desc = bugDescription
        bug.step_to_reproduce = stepsToReproduce
        bug.expected_result = expectedResult
        bug.actual_result = actualResult
        bug.environment = environment
        bug.priority = priority
        bug.severity = severity
        bug.status = status
        bug.device_name = deviceName
        bug.os_version = osVersion
        bug.app_version = appVersion
        bug.due_date = dueDate.formatted(date: .abbreviated, time: .omitted)
        bug.open_date = Date()
        bug.updated_date = Date()
        bug.project_id = project.project_id
        bug.bug_project_relation = project
        bug.reporter_employee_id = employee?.employee_id
        bug.assigned_employee_id = assignedTo
        bug.bug_emaployee_relation = employee
        bug.screenshot = screenshot?.base64EncodedString()

        for draft in attachments {
            let attachment = Attachment(context: context)
            attachment.attachment_id = UUID().uuidString
            attachment.bug_id = bug.bug_id
            attachment.file_name = draft.fileName
            attachment.file_type = draft.fileType.rawValue
            attachment.data = draft.data
            attachment.timestamp = Date()
            attachment.attachment_bug_relation = bug
        }

        context.saveData()
        logActivity(.created, on: bug)
        fetchBugs()
    }

    func updateBug(bug: Bug, bugTitle: String, moduleName: String, bugDescription: String, stepsToReproduce: String, expectedResult: String, actualResult: String, environment: String, priority: String, severity: String, status: String, deviceName: String, osVersion: String, appVersion: String, dueDate: Date, screenshot: Data? = nil, assignedTo: String?, attachments: [BugAttachmentDraft] = []) {
        guard let context = self.context else { return }

        bug.bug_details = bugTitle
        bug.module_name = moduleName
        bug.desc = bugDescription
        bug.step_to_reproduce = stepsToReproduce
        bug.expected_result = expectedResult
        bug.actual_result = actualResult
        bug.environment = environment
        bug.priority = priority
        bug.severity = severity
        bug.status = status
        bug.device_name = deviceName
        bug.os_version = osVersion
        bug.app_version = appVersion
        bug.due_date = dueDate.formatted(date: .abbreviated, time: .omitted)
        bug.screenshot = screenshot?.base64EncodedString()
        bug.assigned_employee_id = assignedTo
        bug.updated_date = Date()

        for draft in attachments {
            let attachment = Attachment(context: context)
            attachment.attachment_id = UUID().uuidString
            attachment.bug_id = bug.bug_id
            attachment.file_name = draft.fileName
            attachment.file_type = draft.fileType.rawValue
            attachment.data = draft.data
            attachment.timestamp = Date()
            attachment.attachment_bug_relation = bug
        }

        context.saveData()
        logActivity(.updated, on: bug)
        fetchBugs()
    }

    func attachments(for bug: Bug) -> [Attachment] {
        let all = (bug.bug_attachment_relation?.allObjects as? [Attachment]) ?? []
        return all.sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    func addAttachment(to bug: Bug, fileName: String, fileType: AttachmentFileType, data: Data) {
        guard let context = self.context else { return }
        let attachment = Attachment(context: context)
        attachment.attachment_id = UUID().uuidString
        attachment.bug_id = bug.bug_id
        attachment.file_name = fileName
        attachment.file_type = fileType.rawValue
        attachment.data = data
        attachment.timestamp = Date()
        attachment.attachment_bug_relation = bug
        bug.updated_date = Date()
        context.saveData()
        logActivity(.attachmentAdded, on: bug)
        fetchBugs()
    }

    func removeAttachment(_ attachment: Attachment) {
        guard let context = self.context else { return }
        let bug = attachment.attachment_bug_relation
        bug?.updated_date = Date()
        context.delete(attachment)
        context.saveData()
        if let bug { logActivity(.attachmentRemoved, on: bug) }
        fetchBugs()
    }

    func developerName(for bug: Bug) -> String {
        guard let id = bug.assigned_employee_id else { return "Unassigned" }
        if let developer = developers.first(where: { $0.employee_id == id }) {
            return developer.employee_name ?? "Unassigned"
        }
        return "Unassigned"
    }

    func shortBugID(for bug: Bug) -> String {
        guard let id = bug.bug_id, !id.isEmpty else { return "N/A" }
        return String(id.prefix(8)).uppercased()
    }

    func assignBug(_ bug: Bug, to developerID: String?) {
        guard let context = self.context else { return }
        bug.assigned_employee_id = developerID
        if developerID != nil,
           BugStatus(rawValue: bug.status ?? BugStatus.open.rawValue) == .open {
            bug.status = BugStatus.assigned.rawValue
            bug.status_updated_date = Date()
        }
        bug.updated_date = Date()
        context.saveData()
        logActivity(.assigned, on: bug)
        fetchBugs()
    }

    func changePriority(_ bug: Bug, to priority: BugPriority) {
        guard let context = self.context else { return }
        bug.priority = priority.rawValue
        bug.updated_date = Date()
        context.saveData()
        logActivity(.priorityChanged, on: bug)
        fetchBugs()
    }

    func allowedTransitions(for bug: Bug, from status: BugStatus) -> [BugStatus] {
        let isAssignedDeveloper = isAssignedDeveloper(for: bug)
        switch status {
        case .open:
            return isProjectManager ? [.assigned] : []
        case .assigned:
            return isAssignedDeveloper ? [.inProgress] : []
        case .inProgress:
            return isAssignedDeveloper ? [.readyForTesting] : []
        case .readyForTesting:
            return isQaTester ? [.fixed, .reopened] : []
        case .fixed:
            return isQaTester ? [.closed, .reopened] : []
        case .reopened:
            return isAssignedDeveloper ? [.inProgress] : []
        case .closed:
            return isProjectManager ? [.reopened] : []
        }
    }

    private func isAssignedDeveloper(for bug: Bug) -> Bool {
        guard isDev,
              let assignedID = bug.assigned_employee_id,
              let employeeID = employee?.employee_id else { return false }
        return assignedID == employeeID
    }

    func updateBugStatus(_ bug: Bug, to status: BugStatus, fixDetails: String? = nil) {
        guard let context = self.context else { return }
        bug.status = status.rawValue
        bug.status_updated_date = Date()
        if let fixDetails,
           !fixDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            bug.fix_details = fixDetails
        }
        if status == .closed {
            bug.close_date = Date()
        } else {
            bug.close_date = nil
        }
        bug.updated_date = Date()
        context.saveData()
        logActivity(.statusChanged, on: bug)
        fetchBugs()
    }


    func addComment(bug: Bug, text: String) {
        guard let context = self.context,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let comment = Comment(context: context)
        comment.comment_id = UUID().uuidString
        comment.bug_id = bug.bug_id
        comment.comment_text = text
        comment.employee_id = employee?.employee_id
        comment.timestamp = Date()
        comment.comment_bug_relation = bug
        comment.comment_employee_relation = employee
        bug.updated_date = Date()
        context.saveData()
        logActivity(.commentAdded, on: bug)
        fetchBugs()
    }

    func editComment(_ comment: Comment, text: String) {
        guard let context = self.context,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        comment.comment_text = text
        comment.timestamp = Date()
        comment.comment_bug_relation?.updated_date = Date()
        context.saveData()
        if let bug = comment.comment_bug_relation { logActivity(.commentEdited, on: bug) }
        fetchBugs()
    }

    func deleteComment(_ comment: Comment) {
        guard let context = self.context else { return }
        let bug = comment.comment_bug_relation
        bug?.updated_date = Date()
        context.delete(comment)
        context.saveData()
        if let bug { logActivity(.commentDeleted, on: bug) }
        fetchBugs()
    }

    func comments(for bug: Bug) -> [Comment] {
        let all = (bug.bug_comment_relation?.allObjects as? [Comment]) ?? []
        return all.sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    func canModifyComment(_ comment: Comment) -> Bool {
        comment.employee_id == employee?.employee_id
    }

    func filteredBugs(for query: String) -> [Bug] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allBugs }
        return allBugs.filter {
            ($0.bug_details ?? "").localizedCaseInsensitiveContains(trimmed) ||
            ($0.bug_id ?? "").localizedCaseInsensitiveContains(trimmed) ||
            ($0.module_name ?? "").localizedCaseInsensitiveContains(trimmed) ||
            ($0.status ?? "").localizedCaseInsensitiveContains(trimmed) ||
            developerName(for: $0).localizedCaseInsensitiveContains(trimmed) ||
            ($0.bug_project_relation?.project_name ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    func statusColor(_ status: String?) -> Color {
        switch status {
        case "Open": return .orange
        case "Assigned": return .teal
        case "In Progress": return .blue
        case "Ready for Testing": return .indigo
        case "Fixed": return .green
        case "Reopened": return .purple
        case "Closed": return .gray
        default: return .secondary
        }
    }

    func priorityColor(_ priority: String?) -> Color {
        switch priority {
        case "Critical": return .red
        case "High": return .orange
        case "Medium": return .blue
        case "Low": return .green
        default: return .secondary
        }
    }

    func severityColor(_ severity: String?) -> Color {
        switch severity {
        case BugSeverity.blocker.rawValue: return .red
        case BugSeverity.critical.rawValue: return .purple
        case BugSeverity.major.rawValue: return .orange
        case BugSeverity.minor.rawValue: return .blue
        default: return .secondary
        }
    }

    // MARK: - Favorites
    private var favoriteBugIDs: Set<String> {
        let raw = employee?.favourite_bug_id ?? ""
        return Set(raw.split(separator: ",").map(String.init))
    }

    func isFavorite(_ bug: Bug) -> Bool {
        guard let id = bug.bug_id else { return false }
        return favoriteBugIDs.contains(id)
    }

    func toggleFavorite(_ bug: Bug) {
        guard let context = self.context, let employee = employee, let id = bug.bug_id else { return }
        var ids = favoriteBugIDs
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        employee.favourite_bug_id = ids.sorted().joined(separator: ",")
        context.saveData()
        fetchBugs()
    }

    // MARK: - Recently Viewed
    private struct RecentBugEntry: Codable {
        let bugID: String
        let timestamp: Date
    }

    private let recentBugsKey = "recentlyViewedBugs"
    private let maxRecentBugs = 10

    func recordRecentlyViewed(_ bug: Bug) {
        guard let id = bug.bug_id else { return }
        var entries = recentEntries
        entries.removeAll { $0.bugID == id }
        entries.insert(RecentBugEntry(bugID: id, timestamp: Date()), at: 0)
        entries = Array(entries.prefix(maxRecentBugs))
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: recentBugsKey)
        }
        recentBugsToken += 1
    }

    var recentlyViewedBugs: [Bug] {
        let entries = recentEntries
        guard !entries.isEmpty, let context = context else { return [] }
        let request = Bug.fetchRequest()
        request.predicate = NSPredicate(format: "bug_id IN %@", entries.map(\.bugID))
        let fetched = (try? context.fetch(request)) ?? []
        var dict: [String: Bug] = [:]
        for bug in fetched {
            if let id = bug.bug_id { dict[id] = bug }
        }
        return entries.compactMap { dict[$0.bugID] }
    }

    private var recentEntries: [RecentBugEntry] {
        guard let data = UserDefaults.standard.data(forKey: recentBugsKey),
              let entries = try? JSONDecoder().decode([RecentBugEntry].self, from: data) else { return [] }
        return entries
    }

    // MARK: - Activity Log
    func logActivity(_ action: ActivityAction, on bug: Bug) {
        guard let context = self.context else { return }
        let log = ActivityLog(context: context)
        log.activity_id = UUID().uuidString
        log.bug_id = bug.bug_id
        log.action = action.rawValue
        log.timestamp = Date()
        log.employee_id = employee?.employee_id
        log.activity_bug_relation = bug
        log.activity_employee_relation = employee
        context.saveData()
    }

    func activityLog(for bug: Bug) -> [ActivityLog] {
        let all = (bug.bug_activity_relation?.allObjects as? [ActivityLog]) ?? []
        return all.sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    func activityTitle(_ action: String?) -> String {
        guard let action = action, let a = ActivityAction(rawValue: action) else { return "Updated" }
        switch a {
        case .created: return "Bug created"
        case .updated: return "Details updated"
        case .statusChanged: return "Status changed"
        case .assigned: return "Bug assigned"
        case .priorityChanged: return "Priority changed"
        case .commentAdded: return "Comment added"
        case .commentEdited: return "Comment edited"
        case .commentDeleted: return "Comment deleted"
        case .attachmentAdded: return "Attachment added"
        case .attachmentRemoved: return "Attachment removed"
        }
    }

    func activityIcon(_ action: String?) -> String {
        guard let action = action, let a = ActivityAction(rawValue: action) else { return "pencil" }
        switch a {
        case .created: return "ladybug.fill"
        case .updated: return "pencil"
        case .statusChanged: return "arrow.triangle.2.circlepath"
        case .assigned: return "person.fill.badge.plus"
        case .priorityChanged: return "flag.fill"
        case .commentAdded: return "bubble.left.fill"
        case .commentEdited: return "bubble.left.and.bubble.right.fill"
        case .commentDeleted: return "trash.fill"
        case .attachmentAdded: return "paperclip"
        case .attachmentRemoved: return "paperclip.badge.minus"
        }
    }

    func activityTint(_ action: String?) -> Color {
        guard let action = action, let a = ActivityAction(rawValue: action) else { return .gray }
        switch a {
        case .created: return .blue
        case .updated: return .teal
        case .statusChanged: return .orange
        case .assigned: return .indigo
        case .priorityChanged: return .red
        case .commentAdded, .commentEdited: return .green
        case .commentDeleted: return .gray
        case .attachmentAdded, .attachmentRemoved: return .purple
        }
    }
}
