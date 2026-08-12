//
//  MyWorkView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 12/08/26.
//

import SwiftUI

struct MyWorkView: View {
    enum Section: String, CaseIterable, Identifiable {
        case myBugs = "My Bugs"
        case notifications = "Notifications"

        var id: String { rawValue }
    }

    @State private var section: Section = .myBugs

    var body: some View {
        VStack(spacing: 0) {
            header
            picker
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(section.rawValue)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private var subtitle: String {
        switch section {
        case .myBugs: return "Bugs assigned to and reported by you"
        case .notifications: return "Assignments, comments, and status updates"
        }
    }

    private var picker: some View {
        Picker("Section", selection: $section) {
            ForEach(Section.allCases) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var content: some View {
        switch section {
        case .myBugs:
            MyBugView(showsHeader: false)
        case .notifications:
            NotificationsView(showsHeader: false)
        }
    }
}

#Preview {
    NavigationStack {
        MyWorkView()
            .environment(BugViewModel())
    }
}
