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
