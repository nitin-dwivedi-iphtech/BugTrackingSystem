//
//  BugDetailsView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import CoreData

struct BugDetailsView: View {
    @Environment(BugViewModel.self) var bugViewModel
    @State private var bug: Bug
    private let bugObjectID: NSManagedObjectID
    @State private var showEditBug: Bool = false
    @State private var showComments: Bool = false
    @State private var isExpanded: Bool = false

    init(bug: Bug) {
        _bug = State(initialValue: bug)
        bugObjectID = bug.objectID
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                keyInfoCard
                knowMoreCard
                commentsButton
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Bug Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if bugViewModel.canEditBug(bug) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditBug = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditBug) {
            BugEditView(bug: bug)
        }
        .sheet(isPresented: $showComments) {
            NavigationStack {
                CommentSectionView(bug: bug)
            }
        }
        .onChange(of: bugViewModel.idCounter) { _, _ in
            guard let refreshed = try? bugViewModel.context?.existingObject(with: bugObjectID) as? Bug else { return }
            bug = refreshed
        }
    }

    @State private var selectedDeveloperID: String = ""

    private var currentStatus: BugStatus {
        BugStatus(rawValue: bug.status ?? "") ?? .open
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(bugViewModel.shortBugID(for: bug))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(bug.bug_details ?? "Untitled Bug")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                BugThumbnailView(bug: bug, size: 64)
            }

            HStack(spacing: 8) {
                badge(bug.status ?? "Open", color: bugViewModel.statusColor(bug.status))
                badge(bug.priority ?? "Medium", color: bugViewModel.priorityColor(bug.priority))
            }

            Text("Severity: \(bug.severity ?? "Major")")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color("appPrimary"), Color("appPrimary").opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(.white))
            .foregroundStyle(color)
    }

    private var keyInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Details", systemImage: "doc.text.magnifyingglass")
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)

            Grid(alignment: .topLeading, horizontalSpacing: 20, verticalSpacing: 14) {
                GridRow {
                    keyValue(icon: "number", title: "Bug ID", value: bugViewModel.shortBugID(for: bug))
                    keyValue(icon: "person.crop.circle", title: "Reporter", value: bug.bug_emaployee_relation?.employee_name ?? "N/A")
                }
                GridRow {
                    keyValue(icon: "person.fill", title: "Assigned To", value: bugViewModel.developerName(for: bug))
                    keyValue(icon: "square.stack.3d.up.fill", title: "Module", value: bug.module_name ?? "N/A")
                }
                GridRow {
                    keyValue(icon: "globe", title: "Environment", value: bug.environment ?? "N/A")
                    keyValue(icon: "iphone", title: "Device", value: bug.device_name ?? "N/A")
                }
                GridRow {
                    keyValue(icon: "apple.logo", title: "OS Version", value: bug.os_version ?? "N/A")
                    keyValue(icon: "apps.iphone", title: "App Version", value: bug.app_version ?? "N/A")
                }
                GridRow {
                    keyValue(icon: "calendar", title: "Open Date", value: bug.open_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                    keyValue(icon: "calendar.badge.exclamationmark", title: "Due Date", value: bug.due_date ?? "N/A")
                }
                GridRow {
                    keyValue(icon: "clock.arrow.circlepath", title: "Updated", value: bug.updated_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                    keyValue(icon: "arrow.triangle.2.circlepath", title: "Status Changed", value: bug.status_updated_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func keyValue(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var knowMoreCard: some View {
        VStack(spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Know More", systemImage: "ellipsis.circle")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appButtonGradient)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                statusWorkflowCard
                if bugViewModel.isProjectManager {
                    priorityCard
                    assigneeCard
                }
                descriptionCard
                stepsCard
                resultsCard
                screenshotCard
            }
        }
    }

    private var commentsButton: some View {
        Button {
            showComments = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appButtonGradient)
                        .frame(width: 40, height: 40)
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.body)
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Comments")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(commentCount == 0 ? "No comments yet" : "\(commentCount) comment\(commentCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private var commentCount: Int {
        bugViewModel.comments(for: bug).count
    }

    private var statusWorkflowCard: some View {
        let transitions = bugViewModel.allowedTransitions(for: bug, from: currentStatus)
        return VStack(alignment: .leading, spacing: 14) {
            Label("Status Workflow", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)

            HStack(spacing: 8) {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(currentStatus.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(bugViewModel.statusColor(currentStatus.rawValue).opacity(0.15), in: Capsule())
                    .foregroundStyle(bugViewModel.statusColor(currentStatus.rawValue))
            }

            if transitions.isEmpty {
                Text("No status change available for your role.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Move to")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        ForEach(transitions) { status in
                            Button {
                                bugViewModel.updateBugStatus(bug, to: status)
                            } label: {
                                VStack(spacing: 5) {
                                    ZStack {
                                        Circle()
                                            .fill(bugViewModel.statusColor(status.rawValue).opacity(0.15))
                                            .frame(width: 28, height: 28)
                                        Circle()
                                            .fill(bugViewModel.statusColor(status.rawValue))
                                            .frame(width: 10, height: 10)
                                    }
                                    Text(status.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.tertiarySystemBackground))
                                        .strokeBorder(
                                            bugViewModel.statusColor(status.rawValue).opacity(0.4),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var priorityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Priority", systemImage: "flag.fill")
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)

            Text("Change the priority of this bug.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(BugPriority.allCases) { priority in
                    Button {
                        bugViewModel.changePriority(bug, to: priority)
                    } label: {
                        Text(priority.rawValue)
                            .font(.caption.weight(bug.priority == priority.rawValue ? .bold : .semibold))
                            .foregroundStyle(
                                bug.priority == priority.rawValue
                                    ? Color.white
                                    : bugViewModel.priorityColor(priority.rawValue)
                            )
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                bug.priority == priority.rawValue
                                    ? AnyShapeStyle(bugViewModel.priorityColor(priority.rawValue))
                                    : AnyShapeStyle(bugViewModel.priorityColor(priority.rawValue).opacity(0.12)),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var assigneeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Assignee", systemImage: "person.fill")
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)

            Picker("Assign To", selection: $selectedDeveloperID) {
                Text("Unassigned").tag("")
                ForEach(bugViewModel.developers, id: \.employee_id) { developer in
                    Text(developer.employee_name ?? "Developer").tag(developer.employee_id ?? "")
                }
            }
            .pickerStyle(.menu)

            Button {
                bugViewModel.assignBug(bug, to: selectedDeveloperID.isEmpty ? nil : selectedDeveloperID)
            } label: {
                Label("Assign", systemImage: "checkmark.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.appButtonGradient)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .onAppear {
            selectedDeveloperID = bug.assigned_employee_id ?? ""
        }
    }

    private var descriptionCard: some View {
        sectionCard(icon: "doc.text", title: "Description") {
            Text(bug.desc ?? "No description")
        }
    }

    private var stepsCard: some View {
        sectionCard(icon: "list.number", title: "Steps to Reproduce") {
            Text(bug.step_to_reproduce ?? "No steps provided")
        }
    }

    private var resultsCard: some View {
        VStack(spacing: 16) {
            sectionCard(icon: "checkmark.circle", title: "Expected Result") {
                Text(bug.expected_result ?? "No expected result")
            }
            sectionCard(icon: "xmark.circle", title: "Actual Result") {
                Text(bug.actual_result ?? "No actual result")
            }
        }
    }

    private var screenshotCard: some View {
        Group {
            if let screenshotString = bug.screenshot,
               let data = Data(base64Encoded: screenshotString),
               let image = UIImage(data: data) {
                sectionCard(icon: "photo.fill", title: "Screenshot") {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func sectionCard(icon: String, title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.appButtonGradient)
            content()
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        BugDetailsView(bug: Bug())
            .environment(BugViewModel())
    }
}
