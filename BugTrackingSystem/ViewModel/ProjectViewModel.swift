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
    var isProjectManager:Bool { SessionManager.shared.isProjectManager }
    var isAdmin:Bool { SessionManager.shared.isAdmin }
    var projects:[Project] = []
    var refreshToken: Int = 0
    private var context:NSManagedObjectContext?
    
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchProjects()
    }
    
    func fetchProjects(){
        if isAdmin {
            let request = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "project_name", ascending: true)]
            do {
                projects = try context?.fetch(request) ?? []
            } catch {
                print("Failed to fetch all projects: \(error)")
                projects = []
            }
        } else {
            guard let team = SessionManager.shared.employee?.employee_team_relation else {
                projects = []
                refreshToken += 1 // for UI update
                return
            }
            projects = (team.team_project_relation?.allObjects as? [Project]) ?? []
        }
        refreshToken += 1 // for UI update
    }
    
    func canEdit(_ project: Project?) -> Bool {
        guard isProjectManager, let project = project else { return false }
        return project.project_team_relation?.team_id == SessionManager.shared.employee?.employee_team_relation?.team_id
    }
    
    @discardableResult
    func createProject(projectName: String, projectDesc: String, projectStartDate: Date, projectStatus: String, projectExpectedDate: Date, projectOsType: String, team: Team?) -> Bool {
        guard let context = self.context, let team = team else { return false }
        let project = Project(context: context)
        project.project_id = UUID().uuidString
        project.project_name = projectName
        project.desc = projectDesc
        project.start_date = projectStartDate
        project.end_date = projectExpectedDate
        project.project_status = projectStatus
        project.project_os = projectOsType
        project.team_id = team.team_id
        project.project_team_relation = team
        context.saveData()
        fetchProjects()
        return true
    }
    
    func deleteProject(_ project: Project) {
        guard let context = self.context else { return }
        if let bugs = project.project_bug_relation?.allObjects as? [Bug] {
            bugs.forEach { bug in
                if let comments = bug.bug_comment_relation?.allObjects as? [Comment] {
                    comments.forEach { context.delete($0) }
                }
                context.delete(bug)
            }
        }
        if let team = project.project_team_relation {
            if let employees = team.team_employee_relation?.allObjects as? [Employee] {
                employees.forEach {
                    $0.team_id = nil
                    $0.employee_team_relation = nil
                }
            }
            context.delete(team)
        }
        context.delete(project)
        context.saveData()
        fetchProjects()
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
