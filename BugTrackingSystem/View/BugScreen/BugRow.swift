//
//  BugRow.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import CoreData

struct BugRow: View {
    @Environment(BugViewModel.self) var bugViewModel
    var bug: Bug

    var body: some View {
        HStack(spacing: 14) {
            BugThumbnailView(bug: bug, size: 52)

            VStack(alignment: .leading, spacing: 5) {
                Text(bug.bug_details ?? "Untitled Bug")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(bug.bug_project_relation?.project_name ?? "No Project")
                    Text("•")
                    Text(bug.module_name ?? "")
                    Text("•")
                    Text(bugViewModel.shortBugID(for: bug))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                    Text(bugViewModel.developerName(for: bug))
                    Text("•")
                    Text(bug.open_date?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 6) {
                severityBadge
                statusBadge
                Text(bug.priority ?? "Medium")
                    .font(.caption2)
                    .foregroundStyle(bugViewModel.priorityColor(bug.priority))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var severityBadge: some View {
        Text(bug.severity ?? BugSeverity.major.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bugViewModel.severityColor(bug.severity).opacity(0.15), in: Capsule())
            .foregroundStyle(bugViewModel.severityColor(bug.severity))
    }

    private var statusBadge: some View {
        Text(bug.status ?? "Open")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bugViewModel.statusColor(bug.status).opacity(0.15), in: Capsule())
            .foregroundStyle(bugViewModel.statusColor(bug.status))
    }
}

#Preview {
    BugRow(bug: Bug())
        .padding()
        .environment(BugViewModel())
}
