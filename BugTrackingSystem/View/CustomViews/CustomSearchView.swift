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
        HStack{
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $query)
        }
        .padding()
        .background(.ultraThinMaterial,in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    CustomSearchView(query: .constant(""))
}
