//
//  AuthViewModel.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import Foundation
import Observation

@Observable
class AuthViewModel {
    var selectedRole: String = RoleEnum.projectManager.rawValue
    var signUp: Bool = false
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var designation: String = ""
    var address: String = ""
    var loading: Bool = false
    var errorMessage: String?

    private let sessionManager = SessionManager.shared

    func toggleSignUp() {
        signUp.toggle()
        errorMessage = nil
    }

    var isFormValid: Bool {
        if signUp {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && !designation.isEmpty && !address.isEmpty
        }
        return !email.isEmpty && !password.isEmpty
    }

    func submit() {
        guard validate() else { return }
        let email = self.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let password = self.password.trimmingCharacters(in: .whitespacesAndNewlines)
        let role = selectedRole.trimmingCharacters(in: .whitespacesAndNewlines)
        
        loading = true
        errorMessage = nil
        Task {
            let success: Bool
            if signUp {
                errorMessage = sessionManager.signUp(email: email, password: password, name: name, address: address, designation: designation, role: role)
                success = true
            } else {
                success = sessionManager.signIn(email: email, password: password, role: role)
            }
            try? await Task.sleep(for: .milliseconds(300))
            loading = false
            if !success {
                errorMessage = "Invalid email, password, or role."
            }
        }
    }

    private func validate() -> Bool {
        if signUp {
            guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !designation.isEmpty, !address.isEmpty else {
                errorMessage = "Please fill in all fields."
                return false
            }
        } else {
            guard !email.isEmpty, !password.isEmpty else {
                errorMessage = "Please enter your email and password."
                return false
            }
        }
        return true
    }
}
