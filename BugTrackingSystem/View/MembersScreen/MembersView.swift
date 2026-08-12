//
//  MembersView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import SwiftUI
import CoreData

struct MembersView: View {
    @State private var viewModel = MembersViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            CustomSearchView(query: $viewModel.query)
            roleFilter
            memberList
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Team Members")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(viewModel.teamMembers.count) members in your project")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private var roleFilter: some View {
        Picker("Role", selection: $viewModel.selectedRole) {
            ForEach(viewModel.roleOptions, id: \.self) { role in
                Text(viewModel.roleLabel(role)).tag(role)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var memberList: some View {
        Group {
            if viewModel.filteredMembers.isEmpty {
                ContentUnavailableView {
                    Label("No Members Found", systemImage: "person.crop.circle.badge.questionmark")
                } description: {
                    Text("No \(viewModel.roleLabel(viewModel.selectedRole)) members in your team yet.")
                }
            } else {
                List {
                    ForEach(viewModel.filteredMembers, id: \.employee_id) { member in
                        MemberRowView(member: member)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

private struct MemberRowView: View {
    var member: Employee

    var body: some View {
        HStack(spacing: 14) {
            avatar
            VStack(alignment: .leading, spacing: 4) {
                Text(member.employee_name ?? "Unknown Member")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(member.email ?? "No email")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let designation = member.designation, !designation.isEmpty {
                    Text(designation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            roleBadge
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var role: String { member.role ?? "Member" }

    private var roleColor: Color {
        switch role {
        case RoleEnum.projectManager.rawValue: return .purple
        case RoleEnum.developer.rawValue: return .blue
        case RoleEnum.qaTester.rawValue: return .orange
        case RoleEnum.admin.rawValue: return .indigo
        default: return .gray
        }
    }

    private var initials: String {
        let parts = (member.employee_name ?? "?").split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    private var avatar: some View {
        ZStack {
            if let photo = member.profile_photo,
               let data = Data(base64Encoded: photo),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [roleColor, roleColor.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Text(initials)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var roleBadge: some View {
        Text(role)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(roleColor.opacity(0.15), in: Capsule())
            .foregroundStyle(roleColor)
    }
}

#Preview {
    NavigationStack {
        MembersView()
    }
}
