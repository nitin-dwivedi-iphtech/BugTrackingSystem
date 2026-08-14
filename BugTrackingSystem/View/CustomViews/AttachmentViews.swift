//
//  AttachmentViews.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 14/08/26.
//

import SwiftUI
import PhotosUI

struct AttachmentRowView: View {
    var fileName: String
    var fileType: AttachmentFileType
    var data: Data?
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(fileType.tint.opacity(0.15))
                    .frame(width: 44, height: 44)
                if fileType == .image, let data, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: fileType.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(fileType.tint)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(fileName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(fileType.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct AddAttachmentButtons: View {
    @Binding var photoItem: PhotosPickerItem?
    @Binding var videoItem: PhotosPickerItem?
    @Binding var isLogImporterPresented: Bool
    var nameFor: (AttachmentFileType) -> String
    var onAdd: (AttachmentFileType, Data, String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                button(icon: "photo", label: "Image", tint: .blue)
            }
            PhotosPicker(selection: $videoItem, matching: .videos) {
                button(icon: "film", label: "Video", tint: .purple)
            }
            Button {
                isLogImporterPresented = true
            } label: {
                button(icon: "doc.text", label: "Log", tint: .orange)
            }
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                    onAdd(.image, data, nameFor(.image))
                }
                photoItem = nil
            }
        }
        .onChange(of: videoItem) { _, newItem in
            Task {
                if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                    onAdd(.video, data, nameFor(.video))
                }
                videoItem = nil
            }
        }
        .fileImporter(isPresented: $isLogImporterPresented, allowedContentTypes: [.plainText, .log], allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first,
                      url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                if let data = try? Data(contentsOf: url) {
                    onAdd(.log, data, url.lastPathComponent)
                }
            case .failure(let error):
                print("Log import failed: \(error)")
            }
        }
    }

    private func button(icon: String, label: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .strokeBorder(Color(.systemGray4), lineWidth: 1)
        )
    }
}