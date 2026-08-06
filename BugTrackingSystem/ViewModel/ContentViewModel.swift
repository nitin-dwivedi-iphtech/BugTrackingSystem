//
//  ContentViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//
import Observation

@Observable
class ContentViewModel {
    var role: String? { SessionManager.shared.employee?.role }

    var isAdmin:Bool {
        guard let role else { return false }
        if RoleEnum.admin.rawValue == role {
            return true
        }
        return false
    }
}
