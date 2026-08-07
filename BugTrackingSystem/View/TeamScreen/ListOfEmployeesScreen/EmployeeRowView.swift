//
//  EmployeeRowView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 07/08/26.
//

import SwiftUI

struct EmployeeRowView : View {
    @Environment(TeamViewModel.self) var teamViewModel
    var employee:Employee
    
    var body: some View{
        let isSelected = teamViewModel.selectedEmployees.contains { $0.employee_id == employee.employee_id }
        
        HStack(spacing: 12) {
            ZStack {
                if let photo = employee.profile_photo, !photo.isEmpty {
                    Image(uiImage: UIImage(data: Data(base64Encoded: photo) ?? Data()) ?? UIImage())
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.appButtonGradient)
                }
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(employee.employee_name ?? "Unknown")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(employee.employee_id ?? "N/A")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                Text(employee.role ?? "Employee")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundStyle(.orange)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? AnyShapeStyle(Color.green) : AnyShapeStyle(Color(.systemGray3)))
                .symbolRenderingMode(.palette)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color("appPrimary").opacity(0.1) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? Color("appPrimary").opacity(0.4) : .clear, lineWidth: 1.5)
        )
    }
}

//#Preview {
//    EmployeeRowView(employee: <#T##Employee#>, selectedEmployee: <#T##() -> Void#>, deSelectedEmployee: <#T##() -> Void#>)
//}
