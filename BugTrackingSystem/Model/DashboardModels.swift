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