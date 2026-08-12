//
//  ProjectDetailView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct ProjectDetailView: View {
    var project: Project
    @Environment(ProjectViewModel.self) var projectViewModel
    @State private var showEditProject: Bool = false

    private var currentProject: Project? {
        guard let projectId = project.project_id else { return project }
        return projectViewModel.projects.first { $0.project_id == projectId } ?? project
    }

    private var members: [Employee] {
        (currentProject?.project_team_relation?.team_employee_relation?.allObjects as? [Employee]) ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                infoCard
                membersCard
            }
            .padding()
        }
        .id(projectViewModel.refreshToken)
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if projectViewModel.canEdit(currentProject) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProject = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showEditProject) {
            ProjectEditView(project: currentProject ?? project)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color("appPrimary"), Color("appPrimary").opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "folder.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            Text(currentProject?.project_name ?? "Unknown Project")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            Text(currentProject?.project_status ?? "Active")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(projectViewModel.statusColor(currentProject?.project_status).opacity(0.15), in: Capsule())
                .foregroundStyle(projectViewModel.statusColor(currentProject?.project_status))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "number", title: "Project ID", value: currentProject?.project_id ?? "N/A")
            Divider()
            infoRow(icon: "calendar", title: "Start Date", value: currentProject?.start_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
            Divider()
            infoRow(icon: "calendar.badge.checkmark", title: "End Date", value: currentProject?.end_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
            Divider()
            infoRow(icon: "doc.text", title: "Description", value: currentProject?.desc ?? "No description")
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.appButtonGradient)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }

    private var membersCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Team Members", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundStyle(Color.appButtonGradient)
                Spacer()
                Text("\(members.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.tertiarySystemBackground)))
                    .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: 1))
            }

            roleBreakdown

            if members.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 30))
                        .foregroundStyle(.secondary)
                    Text("No members assigned to this project")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(members, id: \.employee_id) { employee in
                        memberRow(employee)
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

    private var roleBreakdown: some View {
        HStack(spacing: 8) {
            roleChip(title: "PM", count: members(of: .projectManager), color: .blue)
            roleChip(title: "Dev", count: members(of: .developer), color: .green)
            roleChip(title: "QA", count: members(of: .qaTester), color: .orange)
        }
    }

    private func members(of role: RoleEnum) -> Int {
        members.filter { $0.role == role.rawValue }.count
    }

    private func roleChip(title: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Text("\(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12), in: Capsule())
    }

    private func memberRow(_ employee: Employee) -> some View {
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
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(employee.designation ?? "Designation")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(employee.role ?? "Employee")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(roleColor(employee.role).opacity(0.15), in: Capsule())
                .foregroundStyle(roleColor(employee.role))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private func roleColor(_ role: String?) -> Color {
        switch role {
        case RoleEnum.projectManager.rawValue: return .blue
        case RoleEnum.developer.rawValue: return .green
        case RoleEnum.qaTester.rawValue: return .orange
        default: return .gray
        }
    }
}

//#Preview {
//    NavigationStack {
//        ProjectDetailView(project: Project())
//    }
//}
