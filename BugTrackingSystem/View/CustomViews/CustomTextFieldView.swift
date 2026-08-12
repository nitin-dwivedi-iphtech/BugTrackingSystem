//
//  CustomTextFieldView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI

struct CustomTextFieldView: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var icon:String
    var lineLimit:Int
    
    var body: some View {
        HStack{
            Image(systemName: isSecure ? "lock.fill" : icon)
                .foregroundStyle(.gray)
                .frame(width: 20)
            
            if isSecure{
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text, axis: lineLimit > 1 ? .vertical : .horizontal)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .lineLimit(lineLimit)
            }
        }
        .padding()
        .cornerRadius(12)
    }
}

//#Preview{
//    VStack(spacing: 16){
//        CustomTextFieldView(placeholder: "Email", text: .constant(""))
//        CustomTextFieldView(placeholder: "Password", text: .constant(""), isSecure: true)
//    }
//    .padding()
//}
