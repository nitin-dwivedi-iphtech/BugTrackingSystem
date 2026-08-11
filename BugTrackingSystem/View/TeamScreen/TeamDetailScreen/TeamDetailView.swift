//
//  TeamDetailView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 11/08/26.
//

import SwiftUI
import CoreData

struct TeamDetailView: View {
    @Environment(TeamViewModel.self) var teamViewModel
    var team: Team
    @State private var showEditTeam: Bool = false

    private var currentTeam: Team? {
        guard let teamId = team.team_id else { return team }
        return teamViewModel.teams.first { $0.team_id == teamId } ?? team
    }

    private var members: [Employee] {
        teamViewModel.teamMembers(of: currentTeam ?? team)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                infoCard
                membersCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .id(teamViewModel.refreshToken)
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditTeam = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditTeam) {
            NavigationStack {
                TeamEditView(team: currentTeam ?? team)
            }
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
                    .frame(width: 84, height: 84)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            Text(currentTeam?.team_name ?? "Unknown Team")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Text("\(members.count) members")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color("appPrimary").opacity(0.12), in: Capsule())
                    .foregroundStyle(Color("appPrimary"))
                Text(currentTeam?.project_name ?? "No project")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5), in: Capsule())
                    .foregroundStyle(.secondary)
            }
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
            infoRow(icon: "number", title: "Team ID", value: currentTeam?.team_id ?? "N/A")
            Divider()
            infoRow(icon: "folder.fill", title: "Project", value: currentTeam?.project_name ?? "No project")
            Divider()
            infoRow(icon: "person.2.wave.2.fill", title: "Team Size", value: "\(members.count) members")
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
                    Text("No members in this team")
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

#Preview {
    NavigationStack {
        TeamDetailView(team: Team())
            .environment(TeamViewModel())
    }
}