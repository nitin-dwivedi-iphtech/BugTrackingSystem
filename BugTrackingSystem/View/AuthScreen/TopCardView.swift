//
//  UpwardCardView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 05/08/26.
//

import SwiftUI

struct TopCardView: View {
    var title:String
    var detail:String
    var body: some View {
        ZStack{
            Image("auth_back_image")
                .resizable()
                .scaledToFill()
                .frame(height: 250)
                .clipped()
                .opacity(0.75)
                .overlay(alignment:.leading){
                    VStack(alignment:.leading){
                        Text(title)
                            .font(.title)
                            .bold()
                            .foregroundStyle(.white)
                        
                        Text(detail)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.75))
                    }
                    .padding(.top,35)
                    .padding(.horizontal,30)
                }
        }
        .frame(height: 250)
        .clipShape(ConcentricRectangle())
        .shadow(color:.gray, radius: 10, x:0,y:1)
        .padding(.bottom,15)
        .ignoresSafeArea()
    }
}

//#Preview{
//    TopCardView()
//}
