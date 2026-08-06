//
//  AuthView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI

struct AuthView: View{
    @State private var viewModel = AuthViewModel()
    @State private var adminView: Bool = false
    var body: some View {
        ScrollView{
            VStack{
                if viewModel.signUp{
                    TopCardView(title: "Create Account", detail: "Join BugTrackingSystem and start collaborating with your team.", adminTap: {
                        adminView.toggle()
                        viewModel.signUp.toggle()
                    })
                    
                    if !adminView{
                        rolePicker
                    }
                    roleText
                    signUpBody
                    toggleSignup
                } else {
                    TopCardView(title: "Welcome Back", detail: "Log in to track, assign, and resolve bugs with your team.", adminTap: {
                        adminView.toggle()
                    })
                    
                    if !adminView{
                        rolePicker
                    }
                    roleText
                    loginBody
                    toggleSignup
                }
                
                Spacer()
            }
        }.ignoresSafeArea()
        .onChange(of: adminView) { _, isAdmin in
            viewModel.selectedRole = isAdmin ? RoleEnum.admin.rawValue : RoleEnum.projectManager.rawValue
        }
    }
    
    var signUpBody:some View{
        VStack(spacing:12){
            CustomTextFieldView(placeholder: "Email", text: $viewModel.email, icon:"person.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "password", text: $viewModel.password, isSecure: true, icon: "", lineLimit: 1)
                .padding(.bottom,10)
            
            Divider().padding(.vertical,20)
                .overlay{
                    Text("Detail Info")
                        .padding(.horizontal,10)
                        .background(.white)
                }
            
            CustomTextFieldView(placeholder: "Name", text: $viewModel.name, icon: "person.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Designation", text: $viewModel.designation, icon: "briefcase.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Address", text: $viewModel.address, icon: "mappin.and.ellipse", lineLimit: 1)
                .padding(.bottom,10)
            Button(action:{
                viewModel.submit()
            }){
                authButtonLabel("Sign up")
                    .frame(maxWidth:.infinity)
                    .frame(height: 50)
                    .background(
                        viewModel.isFormValid && !viewModel.loading
                        ? Color.appButtonGradient
                        : LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color("appPrimary").opacity(0.3), radius: 8, y: 4)
            }
            .disabled(!viewModel.isFormValid || viewModel.loading)
            if let errorMessage = viewModel.errorMessage{
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }.padding()
    }
    
    var loginBody: some View{
        VStack(spacing:12){
            CustomTextFieldView(placeholder: "Email", text: $viewModel.email, icon: "envelope.fill", lineLimit: 1)
            CustomTextFieldView(placeholder: "Password", text: $viewModel.password, isSecure: true, icon: "lock.fill", lineLimit: 1)
                .padding(.bottom,10)
            Button(action:{
                viewModel.submit()
            }){
                authButtonLabel("Login in")
                    .frame(maxWidth:.infinity)
                    .frame(height: 50)
                    .background(
                        viewModel.isFormValid && !viewModel.loading
                        ? Color.appButtonGradient
                        : LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color("appPrimary").opacity(0.3), radius: 8, y: 4)
            }
            .disabled(!viewModel.isFormValid || viewModel.loading)
            if let errorMessage = viewModel.errorMessage{
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }.padding()
    }
    
    var rolePicker: some View{
        Picker("Role",selection: $viewModel.selectedRole){
            ForEach(RoleEnum.allCases){ role in
                if role != .admin{
                    Text(role.rawValue).tag(role.rawValue)
                }
            }
            
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        
    }
    
    @ViewBuilder
    private func authButtonLabel(_ title: String) -> some View {
        if viewModel.loading {
            ProgressView()
                .tint(.white)
                .controlSize(.small)
        } else {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
    }
    
    var roleText: some View{
        HStack(spacing: 10){
            Image(systemName: "person.crop.circle.badge.checkmark")
                .foregroundStyle(.gray.opacity(0.5))
            if !adminView{
                Text(RoleEnum.allCases.first(where: { $0.rawValue == viewModel.selectedRole })?.rawValue ?? "No role selected")
                    .font(.title2)
                    .fontWeight(.medium)
            } else {
                Text(RoleEnum.admin.rawValue)
                    .font(.title2)
                    .fontWeight(.medium)
            }
        }
        .padding(.top,30)
    }
    
    @ViewBuilder
    var toggleSignup: some View{
        if !adminView{
            if !viewModel.signUp{
                Text("Don't have an account? Sign up")
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        withAnimation{
                            viewModel.toggleSignUp()
                        }
                    }
            } else {
                Text("Already have an account? Login in")
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        withAnimation{
                            viewModel.toggleSignUp()
                        }
                    }
            }
        }
    }
}

#Preview{
    AuthView()
}
