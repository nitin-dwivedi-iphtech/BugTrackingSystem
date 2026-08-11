//
//  TeamViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import Observation
import CoreData

@Observable
class TeamViewModel {
    var allEmployees: [Employee] = []
    var selectedEmployees:[Employee] = []
    var teams:[Team] = []
    var refreshToken: Int = 0
    var context: NSManagedObjectContext?
    
    init(context:NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchAllEmployee()
        fetchAllTeam()
    }
    
    func fetchAllTeam() {
        do {
            guard let context = self.context else { return }
            let allTeamsRequest = Team.fetchRequest()
            teams = []
            teams = try context.fetch(allTeamsRequest)
            refreshToken += 1 // for UI update
        } catch {
            print("error fetching team")
        }
    }
    
    func fetchAllEmployee(){
        do{
            guard let context = self.context else { return }
            let allEmployeesRequest = Employee.fetchRequest()
            allEmployeesRequest.predicate = NSPredicate(format: "team_id == NULL AND role != %@", RoleEnum.admin.rawValue)
            let data = try context.fetch(allEmployeesRequest)
            allEmployees = [] // forcing ui to re-render
            allEmployees = Array(data)
            refreshToken += 1 // for UI update
        } catch {
            print("All employee busy")
        }
    }
    
    func isTeamValid() -> Bool {
        isTeamValid(employees: selectedEmployees)
    }
    
    func isTeamValid(employees: [Employee]) -> Bool {
        var pMCount: Int = 0
        var devCount: Int = 0
        var qaCount: Int = 0
        for employee in employees {
            if employee.role == RoleEnum.projectManager.rawValue {
                pMCount += 1
            } else if employee.role == RoleEnum.developer.rawValue{
                devCount += 1
            } else if employee.role == RoleEnum.qaTester.rawValue {
                qaCount += 1
            }
        }
        return pMCount == 1 && devCount >= 1 && qaCount >= 1
    }
    
    func teamMembers(of team: Team) -> [Employee] {
        (team.team_employee_relation?.allObjects as? [Employee]) ?? []
    }
    
    func updateTeam(_ team: Team, teamName: String, members: [Employee]) {
        guard let context = self.context else { return }
        for employee in teamMembers(of: team) {
            if !members.contains(where: { $0.employee_id == employee.employee_id }) {
                employee.team_id = nil
                employee.employee_team_relation = nil
            }
        }
        for employee in members {
            employee.team_id = team.team_id
            employee.employee_team_relation = team
        }
        team.team_name = teamName
        context.saveData()
        fetchAllTeam()
        fetchAllEmployee()
    }
    
    func createTeam(projectName: String, projectDesc: String, projectStartDate: Date, projectStatus: String, teamName: String,projectExpectedDate: Date, projectOsType: String) {
        guard let context = self.context else { return }
        let team = Team(context: context)
        team.team_id = UUID().uuidString
        let projectId = createProject(projectName, projectDesc, projectStartDate, projectStatus, team, projectExpectedDate, projectOsType)
        team.project_id = projectId
        team.project_name = projectName
        team.team_name = teamName
        
        for employee in selectedEmployees {
            employee.team_id = team.team_id
            employee.employee_team_relation = team
        }
        
        context.saveData()
        fetchAllTeam()
        fetchAllEmployee()
        
    }
    
    func createProject(_ projectName: String, _ projectDesc: String, _ projectStartDate: Date, _ projectStatus: String, _ team: Team, _ projectExpectedDate: Date, _ projectOsType:String ) -> String{
        guard let context = self.context else { return "" }
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
        
        return project.project_id ?? ""
    }
    
    @discardableResult
    func createEmployee(_ email:String, _ password:String, _ name:String, _ designation:String, _ address:String, _ role:String) -> Bool {
        guard let context = self.context else { return false }
        if employeeExists(email) {
            return false
        }
        let employee = Employee(context: context)
        employee.employee_id = UUID().uuidString
        employee.employee_name = name
        employee.role = role
        employee.email = email.lowercased()
        employee.password = password
        employee.designation = designation
        employee.address = address
        
        context.saveData()
        fetchAllEmployee()
        return true
    }
    
    private func employeeExists(_ email: String) -> Bool {
        guard let context = self.context else { return true }
        let allEmployeesRequest = Employee.fetchRequest()
        allEmployeesRequest.predicate = NSPredicate(format: "email == %@", email.lowercased())
        do {
            return try context.fetch(allEmployeesRequest).first != nil
        } catch {
            print("Error checking employee: \(error)")
            return false
        }
    }
}
