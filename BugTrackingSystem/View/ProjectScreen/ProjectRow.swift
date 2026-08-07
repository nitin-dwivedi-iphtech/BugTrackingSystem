//
//  ProjectRow.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct ProjectRow: View {
    @Environment(ProjectViewModel.self) var projectViewModel
    var project: Project

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color("appPrimary"), Color("appPrimary").opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(project.project_name ?? "Unknown Project")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(project.project_id ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(project.project_status ?? "Active")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(projectViewModel.statusColor(project.project_status).opacity(0.15), in: Capsule())
                .foregroundStyle(projectViewModel.statusColor(project.project_status))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

//#Preview {
//    ProjectRow(project: Project())
//        .padding()
//}
