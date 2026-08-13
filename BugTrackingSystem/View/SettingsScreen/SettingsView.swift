//
//  SettingsView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import SwiftUI
import PhotosUI

struct SettingsView: View {
    @State var viewModel = SettingsViewModel()
    @State var selectedPhotoItem: PhotosPickerItem?
    @AppStorage("darkMode") var darkMode = false

    var body: some View {
        List {
            profileSection
            appearanceSection
            aboutSection
            logoutSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task { await viewModel.loadPhoto(from: newItem) }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
