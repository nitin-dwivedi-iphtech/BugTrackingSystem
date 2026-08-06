//
//  TeamView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct TeamView: View {
    @State private var query: String = ""
    @State private var showAddTeamView:Bool = false
    var body: some View {
        VStack{
            Header
            CustomSearchView(query: $query)
            Button(action:{SessionManager.shared.logOut()}){
                Text("Log out")
            }
            // TODO: list of teams
            Spacer()
        }.sheet(isPresented: $showAddTeamView){
            NavigationStack{
                AddTeamView()
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    var Header: some View{
        HStack{
            Text("Teams")
                .font(.title)
            Spacer()
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.appButtonGradient, in: Circle())
                .shadow(color: Color("appPrimary").opacity(0.35), radius: 6, y: 3)
                .onTapGesture {
                    showAddTeamView = true
                }
        }.padding(.horizontal)
    }
}


#Preview {
    TeamView()
}
