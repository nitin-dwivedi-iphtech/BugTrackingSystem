//
//  DashboardSections.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import Charts

extension DashboardView {
    
    var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Bug Overview", icon: "chart.pie.fill")

            totalBugsCard

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                StatCard(label: "Open Bugs", value: dashboardStats.open, icon: "circle", color: .orange)
                StatCard(label: "Assigned", value: dashboardStats.assigned, icon: "person.badge.plus", color: .teal)
                StatCard(label: "In Progress", value: dashboardStats.inProgress, icon: "clock.fill", color: .blue)
                StatCard(label: "Fixed", value: dashboardStats.fixed, icon: "checkmark.circle.fill", color: .green)
                StatCard(label: "Closed", value: dashboardStats.closed, icon: "lock.fill", color: .gray)
                StatCard(label: "High Priority", value: dashboardStats.highPriority, icon: "exclamationmark.triangle.fill", color: .red)
            }
        }
    }

    var totalBugsCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.18))
                    .frame(width: 64, height: 64)
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(dashboardStats.total)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.white)
                statusBar
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color("appPrimary").opacity(0.9), Color("appPrimary").opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18)
        )
    }

    var statusBar: some View {
        let total = max(dashboardStats.total, 1)
        return VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                HStack(spacing: 3) {
                    ForEach(dashboardStats.byStatus) { item in
                        if item.count > 0 {
                            Capsule()
                                .fill(.white.opacity(0.9))
                                .frame(width: max(4, proxy.size.width * CGFloat(item.count) / CGFloat(total)))
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 8)

            Text(statusSummary)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    var statusSummary: String {
        let s = dashboardStats
        return "\(s.open) open · \(s.inProgress) in progress · \(s.fixed) fixed · \(s.closed) closed"
    }

    var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Status Distribution", icon: "chart.bar.fill")

            VStack(alignment: .leading, spacing: 14) {
                Chart(dashboardStats.byStatus) { item in
                    BarMark(
                        x: .value("Status", item.status),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(bugViewModel.statusColor(item.status))
                    .cornerRadius(6)
                }
                .frame(height: 160)

                legend
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }

    var legend: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading)
        ], spacing: 8) {
            ForEach(dashboardStats.byStatus) { item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(bugViewModel.statusColor(item.status))
                        .frame(width: 8, height: 8)
                    Text("\(item.status) (\(item.count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recently Reported", icon: "clock.arrow.circlepath")

            if recentBugs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "ladybug")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No bugs reported yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            } else {
                ForEach(recentBugs, id: \.bug_id) { bug in
                    NavigationLink(destination: BugDetailsView(bug: bug)) {
                        BugRow(bug: bug)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.title3.weight(.bold))
            .foregroundStyle(.primary)
    }

    var dashboardStats: DashboardStats {
        let bugs = bugViewModel.allBugs
        return DashboardStats(
            total: bugs.count,
            open: count(.open),
            assigned: count(.assigned),
            inProgress: count(.inProgress),
            fixed: count(.fixed),
            closed: count(.closed),
            highPriority: bugs.filter { $0.priority == BugPriority.high.rawValue }.count,
            byStatus: BugStatus.allCases.map { status in
                StatusCount(status: status.rawValue, count: bugs.filter { $0.status == status.rawValue }.count)
            }
        )
    }

    func count(_ status: BugStatus) -> Int {
        bugViewModel.allBugs.filter { $0.status == status.rawValue }.count
    }

    var recentBugs: [Bug] {
        Array(bugViewModel.allBugs
            .sorted { ($0.open_date ?? .distantPast) > ($1.open_date ?? .distantPast) }
            .prefix(5))
    }
}
