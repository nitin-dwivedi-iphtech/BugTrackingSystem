//
//  DashboardView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView{
            VStack(spacing:12){
                Header
                TotalBugCard
                Grid {
                    GridRow {
                        StatCard(title: "Total Bugs", value: "10", icon: "ladybug", color: .red)
                        StatCard(title: "Open", value: "4", icon: "smallcircle.circle", color: .blue)
                    }
                    GridRow {
                        StatCard(title: "In Progress", value: "2", icon: "clock", color: .orange)
                        StatCard(title: "Fixed", value: "3", icon: "checkmark.circle", color: .green)
                    }
                    GridRow {
                        StatCard(title: "Critical", value: "1", icon: "exclamationmark.triangle", color: .purple)
                        StatCard(title: "Blockers", value: "1", icon: "xmark.octagon", color: .red)
                    }
                }
                Button(action:{SessionManager.shared.logOut()}){
                    Text("Logout")
                }
                // TODO: recent bugs part 
                Spacer()
            }
        }
    }
    
    var Header:some View {
        HStack {
            VStack(alignment:.leading){
                Text("Good Morning,")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Priya nair")
                    .font(.title)
                    .bold()
            }
            Spacer()
            Image(systemName: "person.fill")
        }.padding()
        
    }
    
    var TotalBugCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Bugs")
                .font(.title3)
            
            HStack(spacing: 12) {
                Text("10")
                    .font(.system(size:50))
                    .bold()
                
                VStack(alignment: .leading) {
                    HStack {
                        ProgressBar(color: .red, width: 50)
                        ProgressBar(color: .orange, width: 25)
                        ProgressBar(color: .green, width: 10)
                    }
                    
                    Text("3 critical . 2 in progress")
                        .font(.caption)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.opacity(0.4), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func StatCard(title:String, value:String, icon:String, color:Color) -> some View {
        VStack(alignment:.leading,spacing: 12){
            HStack{
                Text(title)
                Spacer()
                Image(systemName: icon)
            }
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color(color))
        }
        .frame(width:150)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
    }
    
    @ViewBuilder
    func ProgressBar(color:UIColor, width:Int) -> some View{
        Text("")
            .frame(minWidth:CGFloat(width), minHeight: 10)
            .background(Color(color).opacity(0.7), in:RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    DashboardView()
}
