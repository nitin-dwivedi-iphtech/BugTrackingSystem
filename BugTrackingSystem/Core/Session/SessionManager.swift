//
//  SessionManager.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//
import Observation
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
        guard let _ = KeyChainHelper.read(key: key) else { return }
        self.isLoggedIn = true
    }
    
    func signUp(email:String, password:String, name:String, address:String, designation:String, role:String){
        KeyChainHelper.save(key: key, value: "\(email):\(password)")
        guard let context = context else { return }
        let employee = Employee(context: context)
        employee.address = address
        employee.email = email.lowercased()
        employee.password = password
        employee.employee_name = name
        employee.role = role
        context.saveData()
        self.isLoggedIn = true
    }
    
    func signIn(email:String, password:String) -> Bool{
        do{
            let request = Employee.fetchRequest()
            request.predicate = NSPredicate(
                format: "email == %@ AND password == %@",
                argumentArray: [email, password]
            )
            let data = try context?.fetch(request)
            if let data, !data.isEmpty{
                self.employee = data.first
                self.isLoggedIn = true
                KeyChainHelper.save(key: key, value: "\(email):\(password)")
                return true
            } else {
                self.isLoggedIn = false
                return false
            }
        } catch{
            print(error)
            return false
        }
    }
    
    func logOut(){
        KeyChainHelper.delete(key: key)
        isLoggedIn = false
    }
}
