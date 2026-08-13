//
//  SettingsViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 13/08/26.
//

import PhotosUI
import CoreData
import Observation
import SwiftUI

@Observable
class SettingsViewModel {
    var profilePhotoData: Data?
    private var context: NSManagedObjectContext?

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadProfilePhoto()
    }

    private var employee: Employee? { SessionManager.shared.employee }

    var displayName: String { employee?.employee_name ?? "User" }
    var email: String { employee?.email ?? "No email" }
    var role: String { employee?.role ?? "Member" }
    var designation: String { employee?.designation ?? "Not specified" }

    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Bug Tracking System"
    }

    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var minimumOS: String {
        Bundle.main.object(forInfoDictionaryKey: "MinimumOSVersion") as? String ?? "26.0"
    }

    func loadProfilePhoto() {
        guard let photo = employee?.profile_photo,
              let data = Data(base64Encoded: photo) else { return }
        profilePhotoData = data
    }

    func loadPhoto(from item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        saveProfilePhoto(data)
    }

    func saveProfilePhoto(_ data: Data) {
        guard let context = context, let employee = employee else { return }
        employee.profile_photo = data.base64EncodedString()
        context.saveData()
        SessionManager.shared.notifyProfileUpdated()
        profilePhotoData = data
    }

    func logOut() {
        SessionManager.shared.logOut()
    }
}