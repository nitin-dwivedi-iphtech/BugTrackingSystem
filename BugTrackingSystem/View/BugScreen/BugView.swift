//
//  BugView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI

struct BugView : View {
    @Environment(BugViewModel.self) var bugViewModel
    @State private var isAddViewPresented:Bool = false
    @State private var query:String  = ""
    @State private var statusFilter: String?
    @State private var priorityFilter: String?
    @State private var severityFilter: String?
    @State private var projectFilter: String?
    @State private var sortOption: SortOption = .date
    @State private var isFilterPanelVisible: Bool = false

    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case priority = "Priority"
        case status = "Status"
        var id: String { rawValue }
    }

    private var hasActiveFilters: Bool {
        statusFilter != nil || priorityFilter != nil || severityFilter != nil || projectFilter != nil
    }

    private var activeFilterCount: Int {
        [statusFilter, priorityFilter, severityFilter, projectFilter].compactMap { $0 }.count
    }

    private var projects: [String] {
        var names = Set<String>()
        for bug in bugViewModel.allBugs {
            if let name = bug.bug_project_relation?.project_name {
                names.insert(name)
            }
        }
        return names.sorted()
    }

    private var displayedBugs: [Bug] {
        var bugs = bugViewModel.filteredBugs(for: query)
        if let statusFilter {
            bugs = bugs.filter { $0.status == statusFilter }
        }
        if let priorityFilter {
            bugs = bugs.filter { $0.priority == priorityFilter }
        }
        if let severityFilter {
            bugs = bugs.filter { $0.severity == severityFilter }
        }
        if let projectFilter {
            bugs = bugs.filter { $0.bug_project_relation?.project_name == projectFilter }
        }
        switch sortOption {
        case .date:
            bugs.sort { ($0.open_date ?? .distantPast) > ($1.open_date ?? .distantPast) }
        case .priority:
            bugs.sort { priorityRank($0.priority) < priorityRank($1.priority) }
        case .status:
            bugs.sort { statusRank($0.status) < statusRank($1.status) }
        }
        return bugs
    }

    private func priorityRank(_ priority: String?) -> Int {
        switch priority {
        case BugPriority.critical.rawValue: return 0
        case BugPriority.high.rawValue: return 1
        case BugPriority.medium.rawValue: return 2
        case BugPriority.low.rawValue: return 3
        default: return 4
        }
    }

    private func statusRank(_ status: String?) -> Int {
        BugStatus.allCases.firstIndex(of: BugStatus(rawValue: status ?? "") ?? .open) ?? 0
    }

    var body: some View {
        VStack{
            header
            CustomSearchView(query: $query)
            if isFilterPanelVisible {
                filterChips
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            if displayedBugs.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(displayedBugs, id: \.bug_id) { bug in
                        NavigationLink(destination: BugDetailsView(bug: bug)) {
                            BugRow(bug: bug)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .sheet(isPresented:$isAddViewPresented) {
            AddBugView()
        }
        .id(bugViewModel.idCounter)
    }

    private var filterChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Filters")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if hasActiveFilters {
                    Button("Clear all") {
                        statusFilter = nil
                        priorityFilter = nil
                        severityFilter = nil
                        projectFilter = nil
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appButtonGradient)
                }
            }
            chipSection(title: "Status", options: BugStatus.allCases.map(\.rawValue), selection: $statusFilter)
            chipSection(title: "Priority", options: BugPriority.allCases.map(\.rawValue), selection: $priorityFilter)
            chipSection(title: "Severity", options: BugSeverity.allCases.map(\.rawValue), selection: $severityFilter)
            if !projects.isEmpty {
                chipSection(title: "Project", options: projects, selection: $projectFilter)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    private func chipSection(title: String, options: [String], selection: Binding<String?>) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button {
                        selection.wrappedValue = nil
                    } label: {
                        chip("All", selected: selection.wrappedValue == nil)
                    }
                    ForEach(options, id: \.self) { option in
                        Button {
                            selection.wrappedValue = (selection.wrappedValue == option ? nil : option)
                        } label: {
                            chip(option, selected: selection.wrappedValue == option)
                        }
                    }
                }
            }
        }
    }

    private func chip(_ label: String, selected: Bool) -> some View {
        Text(label)
            .font(.caption.weight(selected ? .semibold : .regular))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                selected
                    ? AnyShapeStyle(Color.appButtonGradient)
                    : AnyShapeStyle(Color(.secondarySystemBackground)),
                in: Capsule()
            )
            .foregroundStyle(selected ? .white : .primary)
            .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: selected ? 0 : 1))
    }

    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "ladybug")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(emptyMessage)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyMessage: String {
        if hasActiveFilters || sortOption != .date {
            return "No bugs match your filters"
        }
        return query.isEmpty ? "No bugs found" : "No results for \"\(query)\""
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bug Tracking")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("\(bugViewModel.allBugs.count) bugs reported")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFilterPanelVisible.toggle()
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle\(hasActiveFilters ? ".fill" : "")")
                            .font(.title3)
                            .foregroundStyle(Color.appButtonGradient)
                        if activeFilterCount > 0 {
                            Text("\(activeFilterCount)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Circle().fill(.red))
                                .offset(x: 6, y: -6)
                        }
                    }
                }
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                        .foregroundStyle(Color.appButtonGradient)
                }
                if bugViewModel.isProjectManager || bugViewModel.isQaTester{
                    Button(action:{
                        isAddViewPresented = true
                    }){
                        Image(systemName: "plus")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Color("appPrimary"), Color("appPrimary").opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                in: Circle()
                            )
                            .shadow(color: Color("appPrimary").opacity(0.3), radius: 6, y: 3)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview{
    BugView().environment(BugViewModel())
}
