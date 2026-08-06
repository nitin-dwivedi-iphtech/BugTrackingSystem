//
//  Extension.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//
import CoreData

extension NSManagedObjectContext{
    func saveData(){
        do{
            try self.save()
        }catch{
            print(error.localizedDescription)
        }
    }
}

extension Employee {
    static func createAdmin(context: NSManagedObjectContext){
        let employee = Employee(context: context)
        employee.email = "admin@gmail.com"
        employee.password = "123456"
        employee.role = RoleEnum.admin.rawValue
        employee.address = "organization"
        employee.employee_name = "admin"
        employee.employee_id = UUID().uuidString
        
        context.saveData()
    }
}
