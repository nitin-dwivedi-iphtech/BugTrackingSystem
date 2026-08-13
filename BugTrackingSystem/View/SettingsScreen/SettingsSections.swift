//
//  SettingsSections.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import SwiftUI
import PhotosUI

extension SettingsView {

    var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    profileAvatar
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 5) {
                    Text(viewModel.displayName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(viewModel.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.role)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("appPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Color("appPrimary").opacity(0.12), in: Capsule())
                    Text(viewModel.designation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
        } header: {
            Text("Profile")
        } 
    }

    private var profileAvatar: some View {
        ZStack {
            if let data = viewModel.profilePhotoData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("appPrimary"), Color("appPrimary").opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)
                Text(initials)
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            ZStack {
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 28, height: 28)
                Image(systemName: "camera.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("appPrimary"))
            }
            .overlay(Circle().strokeBorder(Color(.systemGray4), lineWidth: 1))
        }
    }

    private var initials: String {
        let parts = viewModel.displayName.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    var appearanceSection: some View {
        Section {
            Toggle(isOn: $darkMode) {
                Label("Dark Mode", systemImage: "moon.stars.fill")
                    .foregroundStyle(.indigo)
            }
            .tint(Color("appPrimary"))
        } header: {
            Text("Appearance")
        } footer: {
            Text("Choose between light and dark appearance.")
        }
    }

    var aboutSection: some View {
        Section {
            LabeledContent("App Name", value: viewModel.appName)
            LabeledContent("Version", value: viewModel.version)
            LabeledContent("Build", value: viewModel.build)
            LabeledContent("Minimum iOS", value: viewModel.minimumOS)
        } header: {
            Text("About App")
        } footer: {
            Text("Track, assign, and resolve bugs with ease.")
        }
    }

    var logoutSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.logOut()
            } label: {
                HStack {
                    Spacer()
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    Spacer()
                }
            }
        } footer: {
            Text("Logging out removes your saved session from this device.")
        }
    }
}
