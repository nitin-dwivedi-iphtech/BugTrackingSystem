//
//  AuthView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI

struct AuthView: View{
    @State private var selectedRole: String = RoleEnum.projectManager.rawValue
    @State private var signUp: Bool = false
    @State private var email: String = ""
    @State private var password:String = ""
    
    @State private var name:String = ""
    @State private var designation:String = ""
    @State private var address:String = ""
    @State private var loading:Bool = false
    @State private var sessionManager = SessionManager.shared
    var body: some View {
        ScrollView{
            if loading{
                VStack(spacing: 12){
                    ProgressView()
                        .controlSize(.large)
                    Text("Please wait...")
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else{
                VStack{
                    if signUp{
                        TopCardView(title: "Create Account", detail: "Join BugTrackingSystem and start collaborating with your team.")
                        rolePicker
                        roleText
                        signUpBody
                        toggleSignup
                    } else {
                        TopCardView(title: "Welcome Back", detail: "Log in to track, assign, and resolve bugs with your team.")
                        rolePicker
                        roleText
                        loginBody
                        toggleSignup
                    }
                    
                    Spacer()
                }
            }
        }.ignoresSafeArea()
    }
    
    var signUpBody:some View{
        VStack(spacing:12){
            CustomTextFieldView(placeholder: "Email", text: $email,icon:"person.fill")
            CustomTextFieldView(placeholder: "password", text: $password, isSecure: true, icon: "")
                .padding(.bottom,10)
            
            Divider().padding(.vertical,20)
                .overlay{
                    Text("Detail Info")
                        .padding(.horizontal,10)
                        .background(.white)
                }
            
            CustomTextFieldView(placeholder: "Name", text: $name, icon: "person.fill")
            CustomTextFieldView(placeholder: "Designation", text: $designation, icon: "briefcase.fill")
            CustomTextFieldView(placeholder: "Address", text: $address, icon: "mappin.and.ellipse")
                .padding(.bottom,10)
            Button(action:{
                if !email.isEmpty && !password.isEmpty && !name.isEmpty && !designation.isEmpty && !address.isEmpty{
                    loading = true
                    sessionManager.signUp(email: email, password: password, name: name, address: address, designation: designation, role: selectedRole)
                }
            }){
                Text("Sign up")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth:.infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .gray.opacity(0.3), radius: 8, y: 4)
            }
        }.padding()
    }
    
    var loginBody: some View{
        VStack(spacing:12){
            CustomTextFieldView(placeholder: "Email", text: $email, icon: "envelope.fill")
            CustomTextFieldView(placeholder: "Password", text: $password, isSecure: true, icon: "lock.fill")
                .padding(.bottom,10)
            Button(action:{
                if !email.isEmpty && !password.isEmpty {
                    loading = true
                    let success = sessionManager.signIn(email: email, password: password)
                    if !success {
                        loading = false
                    }
                }
            }){
                Text("Login in")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth:.infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [.gray, .gray.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .gray.opacity(0.3), radius: 8, y: 4)
            }
        }.padding()
    }
    
    var rolePicker: some View{
        Picker("Role",selection: $selectedRole){
            ForEach(RoleEnum.allCases){ role in
                Text(role.rawValue).tag(role.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    var roleText: some View{
        HStack(spacing: 10){
            Image(systemName: "person.crop.circle.badge.checkmark")
                .foregroundStyle(.gray.opacity(0.5))
            
            Text(RoleEnum.allCases.first(where: { $0.rawValue == selectedRole })?.rawValue ?? "No role selected")
                .font(.title2)
                .fontWeight(.medium)
        }
        .padding(.top,30)
    }
    
    var toggleSignup: some View{
        if !signUp{
            Text("Don't have an account? Sign up")
                .foregroundStyle(.blue)
                .onTapGesture {
                    withAnimation{
                        signUp.toggle()
                    }
                }
        } else {
            Text("Already have an account? Login in")
                .foregroundStyle(.blue)
                .onTapGesture {
                    withAnimation{
                        signUp.toggle()
                    }
                }
        }
    }
}

#Preview{
    AuthView()
}
