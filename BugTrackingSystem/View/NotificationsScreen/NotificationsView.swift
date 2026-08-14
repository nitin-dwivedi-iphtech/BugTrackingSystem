//
//  NotificationsView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import SwiftUI
import CoreData

struct NotificationsView: View {
    @Environment(BugViewModel.self) private var bugViewModel
    @State private var viewModel = NotificationsViewModel()
    var showsHeader: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if showsHeader {
                header
            }
            if viewModel.items.isEmpty {
                emptyState
            } else {
                notificationList
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { viewModel.fetchNotifications() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Notifications")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Assignments, comments, and status updates")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Notifications", systemImage: "bell.slash")
        } description: {
            Text("Assignments, status updates, comments and priority changes will appear here.")
        }
        .frame(maxHeight: .infinity)
    }

    private var notificationList: some View {
        List {
            ForEach(NotificationType.allCases) { type in
                let items = viewModel.items(of: type)
                if !items.isEmpty {
                    Section {
                        ForEach(items) { item in
                            NotificationRow(item: item)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        sectionHeader(type: type, count: items.count)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.fetchNotifications()
        }
    }

    private func sectionHeader(type: NotificationType, count: Int) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(type.tint.opacity(0.14))
                    .frame(width: 34, height: 34)
                Image(systemName: type.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(type.tint)
            }
            Text(type.title)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            Text("\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(.tertiarySystemBackground)))
                .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: 1))
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

private struct NotificationRow: View {
    var item: NotificationItem

    var body: some View {
        NavigationLink(destination: BugDetailsView(bug: item.bug)) {
            HStack(spacing: 14) {
                iconTile
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.message)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(item.relativeTimeString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    private var iconTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [item.type.tint.opacity(0.9), item.type.tint.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
            Image(systemName: item.type.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environment(BugViewModel())
    }
}
