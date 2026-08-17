//
//  BugEnum.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//


enum BugEnvironment: String, CaseIterable, Identifiable {
    case ios = "iOS"
    case android = "Android"
    case web = "Web"

    var id: String { self.rawValue }
}

enum BugSeverity: String, CaseIterable, Identifiable {
    case blocker = "Blocker"
    case critical = "Critical"
    case major = "Major"
    case minor = "Minor"

    var id: String { self.rawValue }
}

enum BugPriority: String, CaseIterable, Identifiable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { self.rawValue }
}

enum BugStatus: String, CaseIterable, Identifiable {
    case open = "Open"
    case assigned = "Assigned"
    case inProgress = "In Progress"
    case readyForTesting = "Ready for Testing"
    case fixed = "Fixed"
    case reopened = "Reopened"
    case closed = "Closed"

    var id: String { self.rawValue }
}

enum ActivityAction: String {
    case created = "created"
    case updated = "updated"
    case statusChanged = "status_changed"
    case assigned = "assigned"
    case priorityChanged = "priority_changed"
    case commentAdded = "comment_added"
    case commentEdited = "comment_edited"
    case commentDeleted = "comment_deleted"
    case attachmentAdded = "attachment_added"
    case attachmentRemoved = "attachment_removed"
}
