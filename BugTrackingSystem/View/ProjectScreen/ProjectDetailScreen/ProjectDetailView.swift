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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                infoCard
            }
            .padding()
        }
        .id(projectViewModel.refreshToken)
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if projectViewModel.isProjectManager {
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

  
}

//#Preview {
//    NavigationStack {
//        ProjectDetailView(project: Project())
//    }
//}
