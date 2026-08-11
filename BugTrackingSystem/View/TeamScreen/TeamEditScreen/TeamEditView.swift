//
//  TeamEditView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 11/08/26.
//

import SwiftUI
import CoreData

struct TeamEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(TeamViewModel.self) private var teamViewModel
    var team: Team

    @State private var teamName: String = ""
    @State private var members: [Employee] = []
    @State private var showAddMembers: Bool = false
    @State private var showInvalidTeamAlert: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Header

            ScrollView {
                VStack(spacing: 18) {
                    teamNameField
                    membersSection
                }
                .padding(.horizontal)
            }

            saveButton
        }
        .navigationBarBackButtonHidden(true)
        .padding(.bottom)
        .onAppear {
            prefill()
        }
        .sheet(isPresented: $showAddMembers) {
            NavigationStack {
                AvailableEmployeesView(selected: $members, team: team)
            }
        }
        .alert("Invalid Team", isPresented: $showInvalidTeamAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A team needs exactly 1 Project Manager, at least 1 Developer, and at least 1 QA Tester.")
        }
    }

    var Header: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text("Edit Team")
                    .font(.title)
                    .fontWeight(.medium)

                Spacer()
            }

            Text("Update the team name and manage its members.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var teamNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Team Name", systemImage: "person.2.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("Team Name", text: $teamName)
                .autocorrectionDisabled()
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Members", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundStyle(Color.appButtonGradient)
                Spacer()
                Button {
                    showAddMembers = true
                } label: {
                    Label("Add Member", systemImage: "person.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.appButtonGradient, in: Capsule())
                        .shadow(color: Color("appPrimary").opacity(0.3), radius: 4, y: 2)
                }
            }

            if members.isEmpty {
                Text("No members in this team yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(.secondary.opacity(0.4))
                    )
            } else {
                ForEach(members, id: \.employee_id) { member in
                    memberRow(member)
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

    private func memberRow(_ member: Employee) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("appPrimary").opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(String(member.employee_name?.prefix(1) ?? "").uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("appPrimary"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(member.employee_name ?? "Unknown")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(member.role ?? "Employee")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                members.removeAll { $0.employee_id == member.employee_id }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    var saveButton: some View {
        Button {
            guard !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            if teamViewModel.isTeamValid(employees: members) {
                teamViewModel.updateTeam(team, teamName: teamName, members: members)
                dismiss()
            } else {
                showInvalidTeamAlert = true
            }
        } label: {
            Label("Save Changes", systemImage: "square.and.arrow.down")
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
        .disabled(teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
    }

    private func prefill() {
        teamName = team.team_name ?? ""
        members = teamViewModel.teamMembers(of: team)
    }
}

#Preview {
    NavigationStack {
        TeamEditView(team: Team())
            .environment(TeamViewModel())
    }
}