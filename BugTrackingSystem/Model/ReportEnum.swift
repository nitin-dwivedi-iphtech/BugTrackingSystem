//
//  ReportEnum.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//


enum ReportType: String, CaseIterable, Identifiable {
    case status = "Status"
    case priority = "Priority"
    case severity = "Severity"
    case project = "Project"
    case monthly = "Monthly"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .status: return "arrow.triangle.2.circlepath"
        case .priority: return "flag.fill"
        case .severity: return "exclamationmark.triangle.fill"
        case .project: return "folder.fill"
        case .monthly: return "calendar"
        }
    }

    var summary: String {
        switch self {
        case .status: return "Bug distribution across lifecycle statuses"
        case .priority: return "Bugs grouped by priority level"
        case .severity: return "Bugs grouped by severity level"
        case .project: return "Bug count for each project in your team"
        case .monthly: return "Bugs reported in the last 12 months"
        }
    }
}
