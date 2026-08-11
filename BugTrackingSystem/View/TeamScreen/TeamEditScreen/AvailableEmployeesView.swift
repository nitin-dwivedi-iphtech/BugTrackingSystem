//
//  AvailableEmployeesView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 11/08/26.
//

import SwiftUI
import CoreData

struct AvailableEmployeesView: View {
    @Environment(TeamViewModel.self) private var teamViewModel
    @Binding var selected: [Employee]
    var team: Team
    @Environment(\.dismiss) private var dismiss

    private var availableEmployees: [Employee] {
        let unassigned = teamViewModel.allEmployees
        let reAddable = teamViewModel.teamMembers(of: team).filter { member in
            !selected.contains { $0.employee_id == member.employee_id }
        }
        return unassigned + reAddable
    }

    var body: some View {
        Group {
            if availableEmployees.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.appButtonGradient)
                    Text("No employees available")
                        .font(.title3.weight(.semibold))
                    Text("Add employees from the Team screen to get more options.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(availableEmployees, id: \.employee_id) { employee in
                        employeeRow(employee)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Add Members")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private func isSelected(_ employee: Employee) -> Bool {
        selected.contains { $0.employee_id == employee.employee_id }
    }

    private func toggle(_ employee: Employee) {
        if isSelected(employee) {
            selected.removeAll { $0.employee_id == employee.employee_id }
        } else {
            selected.append(employee)
        }
    }

    private func employeeRow(_ employee: Employee) -> some View {
        let isSelected = isSelected(employee)
        return Button {
            toggle(employee)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("appPrimary").opacity(0.12))
                        .frame(width: 44, height: 44)
                    Text(String(employee.employee_name?.prefix(1) ?? "").uppercased())
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color("appPrimary"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(employee.employee_name ?? "Unknown")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(employee.role ?? "Employee")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.green : Color(.systemGray3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color("appPrimary").opacity(0.1) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color("appPrimary").opacity(0.4) : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AvailableEmployeesView(selected: .constant([]), team: Team())
            .environment(TeamViewModel())
    }
}