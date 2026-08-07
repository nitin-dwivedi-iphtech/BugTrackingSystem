//
//  ListOfEmployeesView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct ListOfEmployeesView:View {
    @Environment(TeamViewModel.self) var teamViewModel
    @State private var showAddEmployeeView:Bool = false
    var dismiss:()->Void
    var body: some View {
        Group {
            if teamViewModel.allEmployees.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.appButtonGradient)
                    Text("No Employees available")
                        .font(.title3.weight(.semibold))
                    Button {
                        showAddEmployeeView = true
                    } label: {
                        Label("Add Employee", systemImage: "plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.appButtonGradient, in: Capsule())
                            .shadow(color: Color("appPrimary").opacity(0.3), radius: 6, y: 3)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(teamViewModel.allEmployees, id: \.employee_id) { employee in
                        EmployeeRowView(employee: employee)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                if teamViewModel.selectedEmployees.filter({$0.employee_id == employee.employee_id}).count == 0{
                                    Button {
                                        teamViewModel.selectedEmployees.append(employee)
                                    } label: {
                                        Label("Select", systemImage: "checkmark")
                                    }
                                    .tint(Color("appPrimary"))
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                if teamViewModel.selectedEmployees.filter({$0.employee_id == employee.employee_id}).count > 0 {
                                    Button {
                                        teamViewModel.selectedEmployees.removeAll { $0.employee_id == employee.employee_id }
                                    } label: {
                                        Label("Deselect", systemImage: "xmark")
                                    }
                                    .tint(.red)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Available Employees")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddEmployeeView = true
                }) {
                    Label("Add Employee", systemImage: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showAddEmployeeView) {
            NavigationStack {
                AddEmployeeView(isPresented: $showAddEmployeeView)
            }
        }
    }
    
}

//#Preview {
//    ListOfEmployeesView(.environment(TeamViewModel())
//}
