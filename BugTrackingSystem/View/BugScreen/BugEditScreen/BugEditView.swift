//
//  BugEditView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct BugEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BugViewModel.self) var bugViewModel
    var bug: Bug
    
    @State private var bugTitle: String = ""
    @State private var moduleName: String = ""
    @State private var bugDescription: String = ""
    @State private var stepsToReproduce: String = ""
    @State private var expectedResult: String = ""
    @State private var actualResult: String = ""
    @State private var environment: String = BugEnvironment.ios.rawValue
    @State private var priority: String = BugPriority.medium.rawValue
    @State private var severity: String = BugSeverity.major.rawValue
    @State private var status: String = BugStatus.open.rawValue
    @State private var deviceName: String = ""
    @State private var osVersion: String = ""
    @State private var appVersion: String = ""
    @State private var dueDate: Date = Date()
    @State private var attachmentDrafts: [BugAttachmentDraft] = []
    @State private var existingAttachments: [Attachment] = []
    @State private var photoItem: PhotosPickerItem?
    @State private var videoItem: PhotosPickerItem?
    @State private var isLogImporterPresented: Bool = false
    @State private var assignedDeveloperID: String = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            header
            
            Text("Update the bug details and assign it to a developer")
                .font(.caption)
                .foregroundStyle(.primary.opacity(0.6))
                .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    environmentPicker
                    
                    CustomTextFieldView(placeholder: "Bug Title", text: $bugTitle, icon: "ladybug.fill", lineLimit: 1)
                    CustomTextFieldView(placeholder: "Module Name", text: $moduleName, icon: "square.stack.3d.up.fill", lineLimit: 1)
                    CustomTextFieldView(placeholder: "Description", text: $bugDescription, icon: "doc.text", lineLimit: 3)
                    CustomTextFieldView(placeholder: "Steps to Reproduce", text: $stepsToReproduce, icon: "list.number", lineLimit: 4)
                    CustomTextFieldView(placeholder: "Expected Result", text: $expectedResult, icon: "checkmark.circle", lineLimit: 2)
                    CustomTextFieldView(placeholder: "Actual Result", text: $actualResult, icon: "xmark.circle", lineLimit: 2)
                    
                    severityPicker
                    priorityPicker
                    statusPicker
                    
                    if bugViewModel.isProjectManager && !bugViewModel.developers.isEmpty {
                        assigneePicker
                    }
                    
                    CustomTextFieldView(placeholder: "Device Name", text: $deviceName, icon: "iphone", lineLimit: 1)
                    
                    CustomTextFieldView(placeholder: "OS Version", text: $osVersion, icon: "apple.logo", lineLimit: 1)
                    
                    CustomTextFieldView(placeholder: "App Version", text: $appVersion, icon: "apps.iphone", lineLimit: 1)
                    
                    dueDatePicker
                    attachmentsSection
                }
                .padding(.horizontal)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom)
        .onAppear {
            prefill()
        }
    }
    
    var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text("Edit Bug")
                .font(.title)
                .fontWeight(.medium)
            
            Spacer()
            Button {
                bugViewModel.updateBug(
                    bug: bug,
                    bugTitle: bugTitle,
                    moduleName: moduleName,
                    bugDescription: bugDescription,
                    stepsToReproduce: stepsToReproduce,
                    expectedResult: expectedResult,
                    actualResult: actualResult,
                    environment: environment,
                    priority: priority,
                    severity: severity,
                    status: status,
                    deviceName: deviceName,
                    osVersion: osVersion,
                    appVersion: appVersion,
                    dueDate: dueDate,
                    assignedTo: assignedDeveloperID.isEmpty ? nil : assignedDeveloperID,
                    attachments: attachmentDrafts)
                dismiss()
            } label: {
                
                Image(systemName: "square.and.arrow.down")
                    .font(.headline)
                    .foregroundStyle(Color.appButtonGradient)
            }
        }
        .padding()
    }
    
    var environmentPicker: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundStyle(.gray)
                .frame(width: 20)
            
            Picker("Environment", selection: $environment) {
                ForEach(BugEnvironment.allCases, id: \.self) { environment in
                    Text(environment.rawValue).tag(environment.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 8)
    }
    
    var severityPicker: some View {
        HStack {
            Text("Severity")
            Spacer()
            Picker("Bug Severity", selection: $severity) {
                ForEach(BugSeverity.allCases, id: \.self) { severity in
                    Text(severity.rawValue).tag(severity.rawValue)
                }
            }
        }
    }
    
    var priorityPicker: some View {
        HStack {
            Text("Priority")
            Spacer()
            Picker("Bug Priority", selection: $priority) {
                ForEach(BugPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue).tag(priority.rawValue)
                }
            }
        }
    }
    
    var statusPicker: some View {
        HStack {
            Text("Status")
            Spacer()
            Picker("Bug Status", selection: $status) {
                ForEach(BugStatus.allCases, id: \.self) { status in
                    Text(status.rawValue).tag(status.rawValue)
                }
            }
        }
    }
    
    var assigneePicker: some View {
        HStack {
            Text("Assign To")
            Spacer()
            Picker("Assign To Developer", selection: $assignedDeveloperID) {
                Text("Unassigned").tag("")
                ForEach(bugViewModel.developers, id: \.employee_id) { developer in
                    Text(developer.employee_name ?? "Developer").tag(developer.employee_id ?? "")
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    var dueDatePicker: some View {
        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
    }
    
    var attachmentsSection: some View{
        VStack(alignment: .leading, spacing: 10) {
            if !existingAttachments.isEmpty {
                ForEach(existingAttachments, id: \.attachment_id) { attachment in
                    AttachmentRowView(
                        fileName: attachment.file_name ?? "Attachment",
                        fileType: attachmentType(attachment),
                        data: attachment.data
                    ) {
                        bugViewModel.removeAttachment(attachment)
                        existingAttachments = bugViewModel.attachments(for: bug)
                    }
                }
            }
            if !attachmentDrafts.isEmpty {
                ForEach(attachmentDrafts) { draft in
                    AttachmentRowView(
                        fileName: draft.fileName,
                        fileType: draft.fileType,
                        data: draft.data
                    ) {
                        attachmentDrafts.removeAll { $0.id == draft.id }
                    }
                }
            }
            AddAttachmentButtons(
                photoItem: $photoItem,
                videoItem: $videoItem,
                isLogImporterPresented: $isLogImporterPresented,
                nameFor: { type in
                    let count = attachmentDrafts.count + existingAttachments.count
                    switch type {
                    case .image: return "Screenshot \(count + 1).jpg"
                    case .video: return "Screen Recording \(count + 1).mov"
                    case .log: return "Log \(count + 1).txt"
                    }
                },
                onAdd: { type, data, fileName in
                    attachmentDrafts.append(BugAttachmentDraft(
                        fileName: fileName,
                        fileType: type,
                        data: data
                    ))
                }
            )
        }
    }
    
    private func attachmentType(_ attachment: Attachment) -> AttachmentFileType {
        AttachmentFileType(rawValue: attachment.file_type ?? "") ?? .image
    }
    
    private func prefill() {
        bugTitle = bug.bug_details ?? ""
        moduleName = bug.module_name ?? ""
        bugDescription = bug.desc ?? ""
        stepsToReproduce = bug.step_to_reproduce ?? ""
        expectedResult = bug.expected_result ?? ""
        actualResult = bug.actual_result ?? ""
        environment = bug.environment ?? BugEnvironment.ios.rawValue
        priority = bug.priority ?? BugPriority.medium.rawValue
        severity = bug.severity ?? BugSeverity.major.rawValue
        status = bug.status ?? BugStatus.open.rawValue
        deviceName = bug.device_name ?? ""
        osVersion = bug.os_version ?? ""
        appVersion = bug.app_version ?? ""
        if let dueString = bug.due_date,
           let parsed = try? Date(dueString, strategy: .dateTime.day().month(.abbreviated).year()) {
            dueDate = parsed
        }
        assignedDeveloperID = bug.assigned_employee_id ?? ""
        existingAttachments = bugViewModel.attachments(for: bug)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let bug = Bug(context: context)
    bug.bug_details = "Sample bug"
    bug.module_name = "Login"
    bug.due_date = Date().formatted(date: .abbreviated, time: .omitted)
    // set any other fields you want to preview
    
    return NavigationStack {
        BugEditView(bug: bug)
            .environment(BugViewModel(context: context))
    }
}
