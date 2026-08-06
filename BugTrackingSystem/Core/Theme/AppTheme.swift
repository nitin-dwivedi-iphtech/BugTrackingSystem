//
//  AppTheme.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 06/08/26.
//

import SwiftUI

extension Color {
    static let appButtonGradient = LinearGradient(
        colors: [Color("appPrimary"), Color("appPrimary").opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}