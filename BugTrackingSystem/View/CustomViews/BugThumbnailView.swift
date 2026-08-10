//
//  BugThumbnailView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import CoreData

struct BugThumbnailView: View {
    var bug: Bug
    var size: CGFloat = 52

    var body: some View {
        Group {
            if let screenshotString = bug.screenshot,
               let data = Data(base64Encoded: screenshotString),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.23))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.23)
                        .fill(
                            LinearGradient(
                                colors: [Color("appPrimary"), Color("appPrimary").opacity(0.55)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "ladybug.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundStyle(.white)
                }
                .frame(width: size, height: size)
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        BugThumbnailView(bug: Bug(), size: 52)
        BugThumbnailView(bug: Bug(), size: 64)
    }
    .padding()
}