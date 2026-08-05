//
//  ContentView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var sessionManager = SessionManager.shared
    var body: some View {
        if !sessionManager.isLoggedIn{
            AuthView()
        } else {
            Button(action: {
                sessionManager.logOut() 
            }){
                Text("Log out")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
