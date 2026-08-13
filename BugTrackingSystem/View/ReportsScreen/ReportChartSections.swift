//
//  ReportChartSections.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import SwiftUI
import Charts

extension ReportsView {

    private var allBugs: [Bug] { bugViewModel.allBugs }

    var reportPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ReportType.allCases) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedReport = type
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                            Text(type.rawValue)
                        }
                        .font(.subheadline.weight(selectedReport == type ? .semibold : .regular))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedReport == type
                                ? AnyShapeStyle(Color.appButtonGradient)
                                : AnyShapeStyle(Color(.secondarySystemBackground)),
                            in: Capsule()
                        )
                        .foregroundStyle(selectedReport == type ? .white : .primary)
                        .overlay(Capsule().strokeBorder(Color(.systemGray4), lineWidth: selectedReport == type ? 0 : 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    var reportContent: some View {
        VStack(spacing: 16) {
            summaryStrip
            if allBugs.isEmpty {
                emptyState
            } else {
                chartCard
            }
        }
    }

    private var summaryStrip: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            StatCard(label: "Total Bugs", value: allBugs.count, icon: "ladybug.fill", color: .blue)
            StatCard(label: "Open", value: count(.open), icon: "circle", color: .orange)
            StatCard(label: "Fixed", value: count(.fixed), icon: "checkmark.circle.fill", color: .green)
            StatCard(label: "High Priority", value: highPriorityCount, icon: "exclamationmark.triangle.fill", color: .red)
        }
    }

    private func count(_ status: BugStatus) -> Int {
        allBugs.filter { $0.status == status.rawValue }.count
    }

    private var highPriorityCount: Int {
        allBugs.filter {
            $0.priority == BugPriority.high.rawValue || $0.priority == BugPriority.critical.rawValue
        }.count
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Bugs", systemImage: "ladybug")
        } description: {
            Text("Report bugs to see analytics and trends.")
        }
        .padding(.top, 60)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("appPrimary").opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: selectedReport.icon)
                        .font(.body)
                        .foregroundStyle(Color("appPrimary"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bugs by \(selectedReport.rawValue)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(selectedReport.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            chart
                .frame(maxWidth: .infinity)

            if selectedReport == .priority || selectedReport == .severity {
                legend
            } else {
                footer
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @ViewBuilder
    private var chart: some View {
        switch selectedReport {
        case .status:
            statusChart(statusCounts)
        case .priority, .severity:
            donutChart
        case .project:
            projectChart(projectCounts)
        case .monthly:
            monthlyChart(monthlyCounts)
        }
    }

    private var statusCounts: [StatusCount] {
        BugStatus.allCases.map { status in
            StatusCount(status: status.rawValue, count: allBugs.filter { $0.status == status.rawValue }.count)
        }
    }

    private var priorityCounts: [PriorityCount] {
        BugPriority.allCases.map { priority in
            PriorityCount(priority: priority.rawValue, count: allBugs.filter { $0.priority == priority.rawValue }.count)
        }
    }

    private var severityCounts: [SeverityCount] {
        BugSeverity.allCases.map { severity in
            SeverityCount(severity: severity.rawValue, count: allBugs.filter { $0.severity == severity.rawValue }.count)
        }
    }

    private var projectCounts: [ProjectBugCount] {
        projectViewModel.projects
            .map { project in
                ProjectBugCount(
                    projectName: project.project_name ?? "Unnamed Project",
                    count: reportsViewModel.bugCount(for: project)
                )
            }
            .sorted { $0.count > $1.count }
    }

    private var monthlyCounts: [MonthlyBugCount] {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) else { return [] }
        let months = (0..<12).reversed().compactMap { calendar.date(byAdding: .month, value: -$0, to: currentMonth) }
        var counts: [Date: Int] = [:]
        for bug in allBugs {
            guard let date = bug.open_date,
                  let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { continue }
            counts[start, default: 0] += 1
        }
        return months.map { MonthlyBugCount(month: $0, count: counts[$0] ?? 0) }
    }

    private func statusChart(_ data: [StatusCount]) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Count", item.count),
                y: .value("Status", item.status)
            )
            .foregroundStyle(bugViewModel.statusColor(item.status))
            .cornerRadius(5)
        }
        .frame(height: 240)
    }

    private var donutChart: some View {
        ZStack {
            Chart(donutSlices) { slice in
                SectorMark(
                    angle: .value("Count", slice.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(slice.color)
            }
            .frame(height: 220)

            VStack(spacing: 2) {
                Text("\(donutSlices.map(\.count).reduce(0, +))")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                Text("Bugs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func projectChart(_ data: [ProjectBugCount]) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Bugs", item.count),
                y: .value("Project", item.projectName)
            )
            .foregroundStyle(Color("appPrimary"))
            .cornerRadius(5)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: max(240, CGFloat(data.count) * 40))
    }

    private func monthlyChart(_ data: [MonthlyBugCount]) -> some View {
        Chart(data) { item in
            BarMark(
                x: .value("Month", item.month, unit: .month),
                y: .value("Bugs", item.count)
            )
            .foregroundStyle(Color("appPrimary"))
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 2)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .frame(height: 240)
    }

    private struct ReportSlice: Identifiable {
        let id: String
        let label: String
        let count: Int
        let color: Color
    }

    private var donutSlices: [ReportSlice] {
        switch selectedReport {
        case .priority:
            return priorityCounts.map {
                ReportSlice(id: $0.priority, label: $0.priority, count: $0.count, color: bugViewModel.priorityColor($0.priority))
            }
        case .severity:
            return severityCounts.map {
                ReportSlice(id: $0.severity, label: $0.severity, count: $0.count, color: bugViewModel.severityColor($0.severity))
            }
        default:
            return []
        }
    }

    private var legend: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading)
        ], spacing: 10) {
            ForEach(donutSlices) { slice in
                HStack(spacing: 8) {
                    Circle()
                        .fill(slice.color)
                        .frame(width: 10, height: 10)
                    Text(slice.label)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("\(slice.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var footer: some View {
        Label(footerText, systemImage: "info.circle")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var footerText: String {
        switch selectedReport {
        case .status:
            let active = statusCounts.filter { $0.count > 0 }.count
            return "\(allBugs.count) bugs spread across \(active) statuses"
        case .project:
            return "\(allBugs.count) bugs across \(projectCounts.count) projects"
        case .monthly:
            return "\(monthlyCounts.map(\.count).reduce(0, +)) bugs reported in the last 12 months"
        case .priority, .severity:
            return ""
        }
    }
}
