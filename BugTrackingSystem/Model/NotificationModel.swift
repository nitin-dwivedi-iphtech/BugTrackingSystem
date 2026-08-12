//
//  NotificationModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import SwiftUI

enum NotificationType: String, CaseIterable, Identifiable {
    case assigned
    case statusUpdated
    case comment
    case priorityChanged

    var id: String { rawValue }

    var title: String {
        switch self {
        case .assigned: return "Bug Assigned"
        case .statusUpdated: return "Status Updated"
        case .comment: return "Comment Added"
        case .priorityChanged: return "Priority Changed"
        }
    }

    var icon: String {
        switch self {
        case .assigned: return "person.badge.plus"
        case .statusUpdated: return "arrow.triangle.2.circlepath"
        case .comment: return "bubble.left.fill"
        case .priorityChanged: return "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .assigned: return .blue
        case .statusUpdated: return .orange
        case .comment: return .green
        case .priorityChanged: return .red
        }
    }
}

struct NotificationItem: Identifiable {
    let id: UUID
    let type: NotificationType
    let message: String
    let timestamp: Date
    let bug: Bug

    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
