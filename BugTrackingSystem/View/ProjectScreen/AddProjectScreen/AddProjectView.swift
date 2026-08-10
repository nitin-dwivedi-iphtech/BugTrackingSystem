//
//  AddProjectView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (_ name: String, _ desc: String, _ startDate: Date, _ expectedDate: Date, _ status: ProjectStatus, _ osType: ProjectOsTypes) -> Void

    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    @State private var startDate: Date = Date()
    @State private var expectedDate:Date = Date()
    @State private var projectStatus:ProjectStatus = .active
    @State private var projectOsType:ProjectOsTypes = .mobile
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Header
            
            Text("Create a project for your organization with your team members")
                .font(.caption)
                .foregroundStyle(.black.opacity(0.6))
                .padding(.horizontal)
            
            InputFields
            
            Spacer()
            
            saveButton
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom)
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
            
            Text("Add Project")
                .font(.title)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "externaldrive")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    var InputFields: some View {
        VStack(spacing: 12) {
            typePicker
            
            CustomTextFieldView(placeholder: "Project Name", text: $projectName, icon: "folder.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Project brief description", text: $projectDescription, icon: "doc.text", lineLimit: 3)
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("Expected Date", selection: $expectedDate, displayedComponents: .date)
            
            statusPicker
            
        }
        .padding(.horizontal)
    }
    
    var statusPicker: some View{
        HStack{
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
            onSave(projectName, projectDescription, startDate, expectedDate, projectStatus, projectOsType)
            dismiss()
        } label: {
            Label("Save", systemImage: "square.and.arrow.down")
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
}

//#Preview {
//    NavigationStack {
//        AddProjectView()
//    }
//}
