//
//  CustomSearchView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

struct CustomSearchView:View{
    @Binding var query:String
    
    var body: some View{
        HStack(spacing: 10){
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(Color.appButtonGradient)
            
            TextField("Search", text: $query)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .strokeBorder(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: Color("appPrimary").opacity(0.06), radius: 4, y: 2)
        .padding()
    }
}

#Preview {
    CustomSearchView(query: .constant(""))
}
