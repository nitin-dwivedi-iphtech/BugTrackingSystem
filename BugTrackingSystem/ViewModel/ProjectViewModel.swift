//
//  ProjectViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI
import CoreData

@Observable
class ProjectViewModel{
    var role: String? { SessionManager.shared.employee?.role }
    var projects:[Project] = []
    var refreshToken: Int = 0
    private var context:NSManagedObjectContext?
    
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchProjects()
    }
    
    func fetchProjects(){
        let employee = SessionManager.shared.employee
        guard let team = employee?.employee_team_relation else { return }
        projects = (team.team_project_relation?.allObjects as? [Project]) ?? []
        refreshToken += 1 // for UI update
    }
    
    @discardableResult
    func updateProject(byId projectId: String, projectName: String, projectDesc: String, projectStartDate: Date, projectStatus: String, projectExpectedDate: Date, projectOsType: String) -> Bool {
        guard let context = self.context else { return false }
        let request = Project.fetchRequest()
        request.predicate = NSPredicate(format: "project_id == %@", projectId)
        request.fetchLimit = 1
        do {
            guard let project = try context.fetch(request).first else { return false }
            project.project_name = projectName
            project.desc = projectDesc
            project.start_date = projectStartDate
            project.end_date = projectExpectedDate
            project.project_status = projectStatus
            project.project_os = projectOsType
            if let team = project.project_team_relation {
                team.project_name = projectName
            }
            context.saveData()
            fetchProjects()
            return true
        } catch {
            print("Failed to update project: \(error)")
            return false
        }
    }
    
    
    var isProjectManager:Bool{
        guard let role else { return false }
        if RoleEnum.projectManager.rawValue == role {
            return true
        }
        return false
    }
    
    
    func statusColor(_ status: String?) -> Color {
        switch status {
        case ProjectStatus.active.rawValue: return .green
        case ProjectStatus.onHold.rawValue: return .orange
        case ProjectStatus.completed.rawValue: return .blue
        case ProjectStatus.archived.rawValue: return .gray
        default: return .secondary
        }
    }
}
