//
//  MyBugView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 11/08/26.
//

import SwiftUI
import CoreData

struct MyBugView: View {
    @Environment(BugViewModel.self) private var bugViewModel
    @State private var viewModel = MyBugViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            CustomSearchView(query: $viewModel.searchQuery)
            bugList
        }
        .onAppear {
            viewModel.fetchMyBugs()
        }
    }

    private var assignedBugs: [Bug] { viewModel.filteredAssignedBugs }
    private var reportedBugs: [Bug] { viewModel.filteredReportedBugs }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Bugs")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(viewModel.assignedCount) assigned • \(viewModel.reportedCount) reported")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color("appPrimary").opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: "ladybug.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appButtonGradient)
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private var bugList: some View {
        List {
            Section {
                if assignedBugs.isEmpty {
                    emptyRow(message: "No bugs assigned to you")
                } else {
                    ForEach(assignedBugs, id: \.bug_id) { bug in
                        NavigationLink(destination: BugDetailsView(bug: bug)) {
                            BugRow(bug: bug)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                sectionHeader(
                    title: "Assigned to Me",
                    subtitle: "Bugs you are working on",
                    icon: "person.badge.clock",
                    count: viewModel.assignedCount,
                    tint: .blue
                )
            }

            Section {
                if reportedBugs.isEmpty {
                    emptyRow(message: "You haven't reported any bugs yet")
                } else {
                    ForEach(reportedBugs, id: \.bug_id) { bug in
                        NavigationLink(destination: BugDetailsView(bug: bug)) {
                            BugRow(bug: bug)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                sectionHeader(
                    title: "Raised by Me",
                    subtitle: "Bugs you have reported",
                    icon: "person.crop.circle.badge.exclamationmark",
                    count: viewModel.reportedCount,
                    tint: .orange
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(title: String, subtitle: String, icon: String, count: Int, tint: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(tint.opacity(0.14))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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

    private func emptyRow(message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "ladybug")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 24)
            Spacer()
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NavigationStack {
        MyBugView()
            .environment(BugViewModel())
    }
}
