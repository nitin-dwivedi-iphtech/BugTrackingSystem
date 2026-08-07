//
//  SlaphView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI

struct SplashView:View{
    @State private var isActive: Bool = false
    var body: some View{
        if isActive {
            ContentView()
        } else{
            FullSlashView()
                .task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
        }
    }
}

struct FullSlashView:View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20){
            Image(systemName: "ladybug")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .shadow(color: .black.opacity(0.35), radius: 20, y: 10)
                .scaleEffect(scale)
                .opacity(opacity)
            
            VStack(spacing: 8){
                Text("Life Debugger")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Track, assign, and resolve bugs with ease")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color("AppTheme").opacity(0.85), Color("AppTheme")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.4)) {
                scale = 1
                opacity = 1
            }
        }
    }
}

#Preview{
    SplashView()
}
