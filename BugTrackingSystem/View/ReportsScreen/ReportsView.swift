//
//  ReportsView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import SwiftUI

struct ReportsView: View {
    @Environment(BugViewModel.self) var bugViewModel
    @Environment(ProjectViewModel.self) var projectViewModel
    @State var reportsViewModel = ReportsViewModel()
    @State var selectedReport: ReportType = .status

    var body: some View {
        VStack(spacing: 0) {
            reportPicker
            ScrollView {
                reportContent
                    .padding()
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReportsView()
            .environment(BugViewModel())
            .environment(ProjectViewModel())
    }
}
