//
//  ProjectView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct ProjectView:View {
    @Environment(ProjectViewModel.self) var projectViewModel
    @Environment(TeamViewModel.self) var teamViewModel
    @State private var query:String = ""
    @State private var showAddProject: Bool = false
    @State private var projectToDelete: Project?
    @State private var showDeleteConfirm: Bool = false

    private var isAdmin: Bool { projectViewModel.isAdmin }

    private var filteredProjects: [Project] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return projectViewModel.projects }
        return projectViewModel.projects.filter {
            ($0.project_name ?? "").localizedCaseInsensitiveContains(trimmed) ||
            ($0.project_id ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View{
        VStack(spacing: 0){
            Header
            CustomSearchView(query: $query)

            if filteredProjects.isEmpty {
                emptyState
            } else {
                List{
                    ForEach(filteredProjects, id: \.project_id) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)){
                            ProjectRow(project: project)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if isAdmin {
                                Button(role: .destructive) {
                                    projectToDelete = project
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .id(projectViewModel.refreshToken)
            }
        }
        .sheet(isPresented: $showAddProject) {
            NavigationStack {
                AddProjectView(teams: teamViewModel.teams) { name, desc, startDate, expectedDate, status, projectOs, team in
                    projectViewModel.createProject(projectName: name, projectDesc: desc, projectStartDate: startDate, projectStatus: status.rawValue, projectExpectedDate: expectedDate, projectOsType: projectOs.rawValue, team: team)
                }
            }
        }
        .confirmationDialog(
            "Delete Project?",
            isPresented: $showDeleteConfirm,
            presenting: projectToDelete
        ) { project in
            Button("Delete", role: .destructive) {
                projectViewModel.deleteProject(project)
                teamViewModel.fetchAllTeam()
            }
            Button("Cancel", role: .cancel) {}
        } message: { project in
            Text("This will permanently delete \"\(project.project_name ?? "this project")\" along with its team, bugs, and unassign its members. This cannot be undone.")
        }
        .onAppear {
            projectViewModel.fetchProjects()
            teamViewModel.fetchAllTeam()
        }
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No projects found")
                .font(.title3.weight(.semibold))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var Header:some View{
        HStack{
            Text("Projects")
                .font(.title)
                .fontWeight(.medium)
            Spacer()
            if isAdmin {
                Button {
                    showAddProject = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.appButtonGradient, in: Circle())
                        .shadow(color: Color("appPrimary").opacity(0.3), radius: 6, y: 3)
                }
                .accessibilityLabel("Add Project")
            }
        }.padding(.horizontal)
    }
}

#Preview {
    ProjectView()
        .environment(ProjectViewModel())
        .environment(TeamViewModel())
}
