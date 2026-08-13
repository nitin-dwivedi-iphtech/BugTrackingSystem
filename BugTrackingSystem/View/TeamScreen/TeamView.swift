//
//  TeamView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct TeamView: View {
    @Environment(TeamViewModel.self) var teamViewModel
    @State private var query: String = ""
    @State private var showAddTeamView: Bool = false

    private var filteredTeams: [Team] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return teamViewModel.teams }
        return teamViewModel.teams.filter {
            ($0.team_name ?? "").localizedCaseInsensitiveContains(trimmed) ||
            ($0.project_name ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Header
            CustomSearchView(query: $query)

            if filteredTeams.isEmpty {
                emptyState
            } else {
                VStack{
                    List {
                        ForEach(filteredTeams, id: \.team_id) { team in
                            NavigationLink(destination: TeamDetailView(team: team)) {
                                teamRow(team)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .id(teamViewModel.refreshToken)
                }
            }
        }
        .onAppear { teamViewModel.fetchAllTeam() }
        .sheet(isPresented: $showAddTeamView) {
            NavigationStack {
                AddTeamView()
            }
        }
    }

    var Header: some View {
        HStack {
            Text("Teams")
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground), in: Circle())
            }
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.appButtonGradient, in: Circle())
                .shadow(color: Color("appPrimary").opacity(0.35), radius: 6, y: 3)
                .onTapGesture {
                    showAddTeamView = true
                }
        }
        .padding()
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 50))
                .foregroundStyle(Color.appButtonGradient)
            Text("No teams yet")
                .font(.title3.weight(.semibold))
            Text("Tap + to create your first team")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    func teamRow(_ team: Team) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("appPrimary"), Color("appPrimary").opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "person.3.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(team.team_name ?? "Unknown Team")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(team.project_name ?? "No project")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(team.team_employee_relation?.count ?? 0) members")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    TeamView().environment(TeamViewModel())
}
