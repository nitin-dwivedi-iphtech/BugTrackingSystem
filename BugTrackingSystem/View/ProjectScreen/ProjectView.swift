//
//  ProjectView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct ProjectView:View {
    @Environment(ProjectViewModel.self) var projectViewModel
    @State private var query:String = ""

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
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .id(projectViewModel.refreshToken)
            }
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
        }.padding(.horizontal)
    }
}

#Preview {
    ProjectView()
        .environment(ProjectViewModel())
}
