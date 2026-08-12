//
//  MembersViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import CoreData
import Observation

@Observable
class MembersViewModel {
    var selectedRole: RoleEnum? = nil
    var query: String = ""

    var roleOptions: [RoleEnum?] {
        [nil] + [RoleEnum.projectManager, .developer, .qaTester]
    }

    func roleLabel(_ role: RoleEnum?) -> String {
        role?.rawValue ?? "All"
    }

    private var currentEmployee: Employee? {
        SessionManager.shared.employee
    }

    var teamMembers: [Employee] {
        (currentEmployee?.employee_team_relation?.team_employee_relation?.allObjects as? [Employee]) ?? []
    }

    var filteredMembers: [Employee] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return teamMembers
            .filter { employee in
                guard let role = selectedRole else { return true }
                return employee.role == role.rawValue
            }
            .filter { employee in
                guard !trimmed.isEmpty else { return true }
                return (employee.employee_name ?? "").localizedCaseInsensitiveContains(trimmed) ||
                       (employee.email ?? "").localizedCaseInsensitiveContains(trimmed) ||
                       (employee.designation ?? "").localizedCaseInsensitiveContains(trimmed)
            }
            .sorted { ($0.employee_name ?? "").localizedCaseInsensitiveCompare($1.employee_name ?? "") == .orderedAscending }
    }
}
