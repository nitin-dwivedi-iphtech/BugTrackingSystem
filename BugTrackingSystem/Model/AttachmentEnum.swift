//
//  AttachmentEnum.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 14/08/26.
//

import SwiftUI
import UniformTypeIdentifiers

enum AttachmentFileType: String, CaseIterable, Identifiable {
    case image = "Image"
    case video = "Video"
    case log = "Log"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .image: return "photo"
        case .video: return "film"
        case .log: return "doc.text"
        }
    }

    var tint: Color {
        switch self {
        case .image: return .blue
        case .video: return .purple
        case .log: return .orange
        }
    }

    static func from(utType: UTType) -> AttachmentFileType {
        if utType.conforms(to: .movie) { return .video }
        if utType.conforms(to: .plainText) || utType.conforms(to: .log) { return .log }
        return .image
    }
}

struct BugAttachmentDraft: Identifiable {
    let id = UUID()
    let fileName: String
    let fileType: AttachmentFileType
    let data: Data
}
