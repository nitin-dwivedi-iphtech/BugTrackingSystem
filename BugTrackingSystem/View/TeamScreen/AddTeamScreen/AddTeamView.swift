//
//  AddTeamView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct AddTeamView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(TeamViewModel.self) var teamViewModel
    @State private var teamName: String = ""
    @State private var projectName: String = ""
    @State private var projectDesc: String = ""
    @State private var projectStartDate: Date = Date()
    @State private var projectExpectedDate: Date = Date()
    @State private var projectStatus: String = ProjectStatus.active.rawValue
    @State private var projectOsType:String = ProjectOsTypes.mobile.rawValue
    @State private var showAddProject: Bool = false
    @State private var showListOfEmployee: Bool = false
    @State private var showInvalidTeamAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                inputCard
                membersSection
            }
            .padding()
        }
        .navigationTitle("Create Team")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if teamViewModel.isTeamValid() {
                        teamViewModel.createTeam(projectName: projectName, projectDesc: projectDesc, projectStartDate: projectStartDate, projectStatus: projectStatus, teamName: teamName, projectExpectedDate: projectExpectedDate, projectOsType: projectOsType)
                        dismiss()
                    } else {
                        showInvalidTeamAlert = true
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(!isFormValid)
            }
        }
        .sheet(isPresented: $showAddProject) {
            NavigationStack {
                AddProjectView(onSave: { name, desc, startDate, expectedDate, status, projectOs, _ in
                    projectName = name
                    projectDesc = desc
                    projectStartDate = startDate
                    projectStatus = status.rawValue
                    projectExpectedDate = expectedDate
                    projectOsType = projectOs.rawValue
                })
            }
        }
        .sheet(isPresented: $showListOfEmployee) {
            NavigationStack {
                ListOfEmployeesView(dismiss: {
                    showListOfEmployee = false
                })
            }
        }
        .alert("Invalid Team", isPresented: $showInvalidTeamAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A team needs exactly 1 Project Manager, at least 1 Developer, and at least 1 QA Tester.")
        }
    }

    private var isFormValid: Bool {
        !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !teamViewModel.selectedEmployees.isEmpty
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.appButtonGradient)
            Text("Build your team")
                .font(.title2.weight(.semibold))
            Text("Add a team name, a project, and the members who work on it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    private var inputCard: some View {
        VStack(spacing: 16) {
            field(icon: "person.2.fill",
                  placeholder: "Team Name",
                  text: $teamName)

            projectCard
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var projectCard: some View {
        Button {
            showAddProject = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: projectName.isEmpty ? "square.stack.3d.up.fill" : "folder.fill")
                    .font(.body)
                    .foregroundStyle(Color.appButtonGradient)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    if projectName.isEmpty {
                        Text("Add Project")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Text("Name, description, dates, status")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        Text(projectName)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("\(projectStatus) • \(projectStartDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
    }

    private func field(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.appButtonGradient)
                .frame(width: 24)
            TextField(placeholder, text: text)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .strokeBorder(Color(.systemGray4), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var membersSection: some View {
        HStack {
            Text("Members")
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)
            Spacer()
            Button {
                showListOfEmployee = true
            } label: {
                Label("Add Member", systemImage: "person.badge.plus")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.appButtonGradient, in: Capsule())
                    .shadow(color: Color("appPrimary").opacity(0.3), radius: 4, y: 2)
            }
        }
        .padding(.top, 4)

        if teamViewModel.selectedEmployees.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                Text("No members selected")
                    .font(.headline)
                Text("Tap + to pick employees")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .foregroundStyle(.secondary.opacity(0.4))
            )
        } else {
            ForEach(teamViewModel.selectedEmployees, id: \.employee_id) { selectedEmployee in
                HStack(spacing: 8) {
                    EmployeeRowView(employee: selectedEmployee)

                    Button {
                        teamViewModel.selectedEmployees.removeAll { $0.employee_id == selectedEmployee.employee_id }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    AddTeamView().environment(TeamViewModel())
}
