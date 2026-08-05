//
//  RoleEnum.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

enum RoleEnum: String, Identifiable, CaseIterable {
    case projectManager = "Project Manager"
    case developer = "Developer"
    case qaTester = "QA Tester"
    
    var id: String { rawValue }
}
