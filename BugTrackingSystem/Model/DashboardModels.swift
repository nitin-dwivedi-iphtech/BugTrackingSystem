//
//  DashboardModels.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import Foundation

struct StatusCount: Identifiable {
    let status: String
    let count: Int
    var id: String { status }
}

struct DashboardStats {
    let total: Int
    let open: Int
    let assigned: Int
    let inProgress: Int
    let fixed: Int
    let closed: Int
    let highPriority: Int
    let byStatus: [StatusCount]
}

struct PriorityCount: Identifiable {
    let priority: String
    let count: Int
    var id: String { priority }
}

struct SeverityCount: Identifiable {
    let severity: String
    let count: Int
    var id: String { severity }
}

struct ProjectBugCount: Identifiable {
    let projectName: String
    let count: Int
    var id: String { projectName }
}

struct MonthlyBugCount: Identifiable {
    let month: Date
    let count: Int
    var id: Date { month }
}
