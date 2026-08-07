//
//  AddEmployeeView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct AddEmployeeView : View {
    @Environment(TeamViewModel.self) var teamViewModel
    @Binding var isPresented: Bool
    @State private var employeeName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var designation: String = ""
    @State private var address: String = ""
    @State private var selectedRole: String = RoleEnum.developer.rawValue
    @State private var showExistsAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                roleHeader
                rolePicker
                
                CustomTextFieldView(placeholder: "Employee Name", text: $employeeName, icon: "person.fill", lineLimit: 1)
                CustomTextFieldView(placeholder: "Role", text: .constant(selectedRole), icon: "person.badge.shield.checkmark.fill", lineLimit: 1)
                
                Divider()
                    .padding(.vertical, 12)
                    .overlay {
                        Text("Detail Info")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .background(Color(.systemBackground))
                    }
                
                CustomTextFieldView(placeholder: "Email", text: $email, icon: "envelope.fill", lineLimit: 1)
                CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, icon: "lock.fill", lineLimit: 1)
                CustomTextFieldView(placeholder: "Designation", text: $designation, icon: "briefcase.fill", lineLimit: 1)
                CustomTextFieldView(placeholder: "Address", text: $address, icon: "mappin.and.ellipse", lineLimit: 1)
            }
            .padding()
        }
        .navigationTitle("Create Employee")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let created = teamViewModel.createEmployee(email, password, employeeName, designation, address, selectedRole)
                    if created {
                        isPresented = false
                    } else {
                        showExistsAlert = true
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .disabled(!isFormValid)
            }
        }
        .alert("Employee Already Exists", isPresented: $showExistsAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("An employee with this email, password, and role is already registered.")
        }
    }
    
    var roleHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .foregroundStyle(.gray.opacity(0.5))
            Text(selectedRole)
                .font(.title3)
                .fontWeight(.medium)
        }
    }
    
    var rolePicker: some View {
        Picker("Role", selection: $selectedRole) {
            ForEach(RoleEnum.allCases) { role in
                if role != .admin{
                    Text(role.rawValue).tag(role.rawValue)
                }
            }
        }
        .pickerStyle(.segmented)
    }
    
    var isFormValid: Bool {
        !employeeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    NavigationStack {
        AddEmployeeView(isPresented: .constant(true))
    }
}
