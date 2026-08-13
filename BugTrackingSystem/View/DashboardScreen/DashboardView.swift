//
//  DashboardView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(BugViewModel.self) var bugViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerBanner
                reportsEntry
                overviewSection
                statusSection
                recentSection
            }
            .padding()
        }
        .id(bugViewModel.idCounter)
            .navigationTitle("Dashboard")
        .scrollIndicators(.hidden)
    }

    private var headerBanner: some View {
        HStack(spacing: 14) {
            avatarView
            VStack(alignment: .leading, spacing: 5) {
                Text(greeting)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                Text(employeeName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                Text(roleLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.2), in: Capsule())
            }
            Spacer()
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.2), in: Circle())
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color("appPrimary"), Color("appPrimary").opacity(0.62)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var avatarView: some View {
        ZStack {
            if let photo = SessionManager.shared.employee?.profile_photo,
               let data = Data(base64Encoded: photo),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.3), lineWidth: 2))
            } else {
                Text(String(employeeName.prefix(1)).uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("appPrimary"))
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(.white))
            }
        }
        .id(SessionManager.shared.profileUpdateToken)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var employeeName: String {
        SessionManager.shared.employee?.employee_name ?? "User"
    }

    private var roleLabel: String {
        SessionManager.shared.employee?.role ?? ""
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environment(BugViewModel())
    }
}
