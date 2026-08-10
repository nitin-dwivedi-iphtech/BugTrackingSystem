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
            SubView()
        }
    }
}

struct SubView:View {
    @State private var projectViewModel = ProjectViewModel()
    @State private var contentVewModel = ContentViewModel()
    @State private var teamViewModel = TeamViewModel()
    @State private var bugViewModel = BugViewModel()
    var body: some View {
        if contentVewModel.isAdmin{
            TabView{
                NavigationStack {
                    TeamView()
                }.tag(0)
                    .tabItem{
                        Label("Team",systemImage: "person.3.fill")
                    }
            }
            .environment(teamViewModel)
            .ignoresSafeArea()
        } else {
            TabView {
                NavigationStack{
                    DashboardView()
                }.tag(0)
                .tabItem{
                    Label("Dashboard",systemImage: "square.grid.2x2.fill")
                }
                
                NavigationStack {
                    ProjectView()
                }.tag(1)
                    .tabItem{
                        Label("Project",systemImage: "hammer.fill")
                    }
                
                NavigationStack {
                    BugView()
                }.tag(1)
                    .tabItem{
                        Label("Bug",systemImage: "ladybug")
                    }
            }
            .ignoresSafeArea()
            .environment(projectViewModel)
            .environment(bugViewModel)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
