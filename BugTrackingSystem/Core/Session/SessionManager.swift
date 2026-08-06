//
//  SessionManager.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//
import SwiftUI
import CoreData

@Observable
class SessionManager{
    static let shared = SessionManager()
    var isLoggedIn: Bool = false
    var context:NSManagedObjectContext?
    var employee:Employee?
    private let key = "token"
    
    private init(){
        context = PersistenceController.shared.container.viewContext
        autoLogin()
    }
    
    private func fetchEmployee(email:String, password:String, role:String) -> Employee? {
        do{
            let request = Employee.fetchRequest()
            request.predicate = NSPredicate(
                format: "email == %@ AND password == %@ AND role == %@",
                argumentArray: [email, password, role]
            )
            guard let data = try context?.fetch(request) else { return nil }
            return data.first
        }catch{
            print("Employee not found in core data")
            return  nil
        }
    }
    
    func signUp(email:String, password:String, name:String, address:String, designation:String, role:String) -> String?{
        guard let context = context else { return nil}
        let data = fetchEmployee(email: email, password: password, role: role)
        if data != nil{
            return "Employee already exists"
        }
       
        let employee = Employee(context: context)
        employee.address = address
        employee.email = email
        employee.password = password
        employee.employee_name = name
        employee.role = role
        context.saveData()
        
        KeyChainHelper.save(key: key, value: "\(email):\(password):\(role)")
        self.isLoggedIn = true
        self.employee = employee
        return nil
    }
    
    func signIn(email:String, password:String, role:String) -> Bool{
        let data = fetchEmployee(email: email, password: password, role: role)
        if let data{
            self.employee = data
            self.isLoggedIn = true
            KeyChainHelper.save(key: key, value: "\(email):\(password):\(role)")
            return true
        } else {
            self.isLoggedIn = false
            return false
        }
        
    }
    
    private func autoLogin(){
        guard let value  = KeyChainHelper.read(key: key) else { return }
        let components = value.split(separator: ":")
        guard let email = components.first, let role = components.last else { return }
        let password = components[1]
        
        let data = fetchEmployee(email: String(email), password: String(password), role: String(role))
        if let data{
            self.isLoggedIn = true
            self.employee = data
        }
        
    }
    
    func logOut(){
        KeyChainHelper.delete(key: key)
        isLoggedIn = false
    }
}
