//
//  ProjectEditView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct ProjectEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProjectViewModel.self) private var projectViewModel
    var project: Project

    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var projectStatus: ProjectStatus = .active
    @State private var projectOsType: ProjectOsTypes = .mobile

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Header

            InputFields

            Spacer()

            saveButton
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom)
        .onAppear {
            prefill()
        }
    }

    var Header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Text("Edit Project")
                .font(.title)
                .fontWeight(.medium)

            Spacer()
        }
        .padding()
    }

    var InputFields: some View {
        VStack(spacing: 12) {
            typePicker

            CustomTextFieldView(placeholder: "Project Name", text: $projectName, icon: "folder.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Project brief description", text: $projectDescription, icon: "doc.text", lineLimit: 3)

            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("Expected Date", selection: $endDate, displayedComponents: .date)

            statusPicker
        }
        .padding(.horizontal)
    }

    var statusPicker: some View {
        HStack {
            Text("Status")
            Spacer()
            Picker("Project Status", selection: $projectStatus) {
                ForEach(ProjectStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }

    var typePicker: some View {
        HStack {
            Image(systemName: "app.connected.to.app.below.fill")
                .foregroundStyle(.gray)
                .frame(width: 20)

            Picker("Project OS Type", selection: $projectOsType) {
                ForEach(ProjectOsTypes.allCases, id: \.self) { osType in
                    Text(osType.rawValue).tag(osType)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 8)
    }

    var saveButton: some View {
        Button {
            if let projectId = project.project_id {
                projectViewModel.updateProject(
                    byId: projectId,
                    projectName: projectName,
                    projectDesc: projectDescription,
                    projectStartDate: startDate,
                    projectStatus: projectStatus.rawValue,
                    projectExpectedDate: endDate,
                    projectOsType: projectOsType.rawValue
                )
            }
            dismiss()
        } label: {
            Label("Save Changes", systemImage: "square.and.arrow.down")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appButtonGradient)
                .clipShape(Capsule())
                .shadow(color: Color("appPrimary").opacity(0.3), radius: 8, y: 4)
        }
        .padding(.horizontal)
        .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }

    private func prefill() {
        projectName = project.project_name ?? ""
        projectDescription = project.desc ?? ""
        startDate = project.start_date ?? Date()
        endDate = project.end_date ?? Date()
        projectStatus = ProjectStatus(rawValue: project.project_status ?? "") ?? .active
        projectOsType = ProjectOsTypes(rawValue: project.project_os ?? "") ?? .mobile
    }
}
