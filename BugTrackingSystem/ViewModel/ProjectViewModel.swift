//
//  ProjectViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import Observation

@Observable
class ProjectViewModel{
    var role: String? { SessionManager.shared.employee?.role }
    
    var isProjectManager:Bool{
        guard let role else { return false }
        if RoleEnum.projectManager.rawValue == role {
            return true
        }
        return false
    }
}
