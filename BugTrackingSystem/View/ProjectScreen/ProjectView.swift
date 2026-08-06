//
//  ProjectView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct ProjectView:View {
    @Environment(ProjectViewModel.self) var projectViewModel
    @State private var query:String = ""
    @State private var showProjectAddView:Bool = false
    var body: some View{
        ScrollView{
            VStack{
                Header
                CustomSearchView(query: $query)
                List{
                    //TODO: projects list to be shown
                }
            }
        }.sheet(isPresented:$showProjectAddView){
            NavigationStack{
                AddProjectView()
            }
        }
    }
    
    var Header:some View{
        HStack{
            Text("Projects")
                .font(.title)
                .fontWeight(.medium)
            if projectViewModel.isProjectManager{
                Spacer()
                Button(action:{
                    showProjectAddView = true
                }){
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.appButtonGradient, in: Circle())
                        .shadow(color: Color("appPrimary").opacity(0.35), radius: 6, y: 3)
                }
            }
        }.padding(.horizontal)
    }
}

#Preview {
    ProjectView()
        .environment(ProjectViewModel())
}
