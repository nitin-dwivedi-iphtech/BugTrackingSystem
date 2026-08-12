//
//  AddBugView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import PhotosUI

struct AddBugView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BugViewModel.self) var bugViewModel
    @Environment(ProjectViewModel.self) var projectViewModel

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
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var screenshotData: Data?
    @State private var assignedDeveloperID: String = ""
    @State private var selectedProjectID: String? = nil

    private var isFormValid: Bool {
        !bugTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var showsProjectPicker: Bool {
        bugViewModel.isProjectManager && !projectViewModel.projects.isEmpty
    }

    private var showsAssigneePicker: Bool {
        bugViewModel.isProjectManager && !bugViewModel.developers.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            subtitle
            ScrollView {
                VStack(spacing: 16) {
                    bugInfoCard
                    reproductionCard
                    contextCard
                    classificationCard
                    assignmentCard
                    deviceCard
                    scheduleCard
                    attachmentCard
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            saveButton
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if selectedProjectID == nil,
               let projectID = bugViewModel.employee?.employee_team_relation?.team_project_relation?.allObjects.first as? Project {
                selectedProjectID = projectID.project_id
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground), in: Circle())
            }

            Spacer()

            Text("Add Bug")
                .font(.title2.weight(.bold))

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var subtitle: some View {
        Text("Report a bug with the details needed to reproduce and fix it")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }

    private var bugInfoCard: some View {
        card(title: "Bug Information", icon: "ladybug.fill") {
            CustomTextFieldView(placeholder: "Bug Title", text: $bugTitle, icon: "exclamationmark.circle", lineLimit: 1)
            CustomTextFieldView(placeholder: "Module Name", text: $moduleName, icon: "square.stack.3d.up.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Description", text: $bugDescription, icon: "doc.text", lineLimit: 3)
        }
    }

    private var reproductionCard: some View {
        card(title: "How to Reproduce", icon: "list.number") {
            CustomTextFieldView(placeholder: "Steps to Reproduce", text: $stepsToReproduce, icon: "list.number", lineLimit: 4)
            CustomTextFieldView(placeholder: "Expected Result", text: $expectedResult, icon: "checkmark.circle", lineLimit: 2)
            CustomTextFieldView(placeholder: "Actual Result", text: $actualResult, icon: "xmark.circle", lineLimit: 2)
        }
    }

    @ViewBuilder
    private var contextCard: some View {
        card(title: "Context", icon: "globe") {
            if showsProjectPicker {
                fieldRow("Project") {
                    Picker("Project", selection: $selectedProjectID) {
                        Text("Select Project").tag(nil as String?)
                        ForEach(projectViewModel.projects, id: \.project_id) { project in
                            Text(project.project_name ?? "Project").tag(project.project_id)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Divider()
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Platform")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Picker("Platform", selection: $environment) {
                    ForEach(BugEnvironment.allCases, id: \.self) { environment in
                        Text(environment.rawValue).tag(environment.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var classificationCard: some View {
        card(title: "Classification", icon: "slider.horizontal.3") {
            fieldRow("Severity") {
                Picker("Severity", selection: $severity) {
                    ForEach(BugSeverity.allCases, id: \.self) { severity in
                        Text(severity.rawValue).tag(severity.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            Divider()
            fieldRow("Priority") {
                Picker("Priority", selection: $priority) {
                    ForEach(BugPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
            Divider()
            fieldRow("Status") {
                Picker("Status", selection: $status) {
                    ForEach(BugStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }

    @ViewBuilder
    private var assignmentCard: some View {
        if showsAssigneePicker {
            card(title: "Assignment", icon: "person.fill.badge.plus") {
                fieldRow("Assign To") {
                    Picker("Assign To", selection: $assignedDeveloperID) {
                        Text("Unassigned").tag("")
                        ForEach(bugViewModel.developers, id: \.employee_id) { developer in
                            Text(developer.employee_name ?? "Developer").tag(developer.employee_id ?? "")
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    private var deviceCard: some View {
        card(title: "Device Details", icon: "iphone") {
            CustomTextFieldView(placeholder: "Device Name", text: $deviceName, icon: "iphone", lineLimit: 1)
            CustomTextFieldView(placeholder: "OS Version", text: $osVersion, icon: "apple.logo", lineLimit: 1)
            CustomTextFieldView(placeholder: "App Version", text: $appVersion, icon: "apps.iphone", lineLimit: 1)
        }
    }

    private var scheduleCard: some View {
        card(title: "Schedule", icon: "calendar") {
            HStack(spacing: 12) {
                Text("Due Date")
                    .foregroundStyle(.primary)
                Spacer()
                DatePicker("", selection: $dueDate, displayedComponents: .date)
                    .labelsHidden()
            }
        }
    }

    private var attachmentCard: some View {
        card(title: "Screenshot", icon: "photo") {
            attachmentButton
        }
    }

    private func card<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }

    private func fieldRow<Content: View>(_ title: String, @ViewBuilder control: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            control()
        }
    }

    private var saveButton: some View {
        Button {
            saveBug()
        } label: {
            Label("Save Bug", systemImage: "square.and.arrow.down")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.appButtonGradient)
                .clipShape(Capsule())
                .shadow(color: Color("appPrimary").opacity(0.3), radius: 8, y: 4)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1 : 0.5)
    }

    private var attachmentButton: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            HStack(spacing: 12) {
                Image(systemName: screenshotData == nil ? "plus.circle.fill" : "photo.fill")
                    .foregroundStyle(Color.appButtonGradient)
                    .frame(width: 24)

                Text(screenshotData == nil ? "Add Screenshot" : "1 attachment")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()

                if let screenshotData, let image = UIImage(data: screenshotData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button {
                        self.screenshotData = nil
                        selectedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                } else {
                    Text("No attachment")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
            )
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    screenshotData = data
                }
            }
        }
    }

    private func saveBug() {
        bugViewModel.createBug(
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
            screenshot: screenshotData,
            assignedTo: assignedDeveloperID.isEmpty ? nil : assignedDeveloperID,
            projectID: selectedProjectID)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddBugView()
            .environment(BugViewModel())
            .environment(ProjectViewModel())
    }
}
