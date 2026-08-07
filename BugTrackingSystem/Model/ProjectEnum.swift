//
//  ProjectEnum.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

enum ProjectStatus: String, CaseIterable, Identifiable {
    case active = "Active"
    case onHold = "On Hold"
    case completed = "Completed"
    case archived = "Archived"
    
    var id:String { self.rawValue }
}

enum ProjectOsTypes: String, CaseIterable, Identifiable {
    case mobile = "Mobile"
    case web = "Web"
    case desktop = "Desktop"
    
    var id: String { self.rawValue }
}
