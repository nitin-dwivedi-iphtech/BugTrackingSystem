//
//  CommentSectionView.swift
//  BugTrackingSystem
//
//  Created by iPHTech 40 on 10/08/26.
//

import SwiftUI
import CoreData

struct CommentSectionView: View {
    @Environment(BugViewModel.self) var bugViewModel
    @Environment(\.dismiss) private var dismiss
    var bug: Bug

    @State private var comments: [Comment] = []
    @State private var commentText: String = ""
    @State private var editingComment: Comment?
    @State private var editText: String = ""
    @State private var commentToDelete: Comment?
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        Group {
            if comments.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(comments, id: \.comment_id) { comment in
                            commentRow(comment)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            commentComposer
                .padding()
                .background(.bar)
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            reload()
        }
        .confirmationDialog(
            "Delete this comment?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible,
            presenting: commentToDelete
        ) { comment in
            Button("Delete", role: .destructive) {
                deleteComment(comment)
            }
        } message: { _ in
            Text("This cannot be undone.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No comments yet.")
                .font(.title3.weight(.semibold))
            Text("Start the conversation by adding the first comment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var commentComposer: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Add a comment…", text: $commentText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )

            Button {
                addComment()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.appButtonGradient, in: Circle())
            }
            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            avatar(for: comment)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(comment.comment_employee_relation?.employee_name ?? "Unknown")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(comment.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if bugViewModel.canModifyComment(comment) {
                        Menu {
                            Button {
                                editingComment = comment
                                editText = comment.comment_text ?? ""
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                commentToDelete = comment
                                showDeleteConfirm = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if editingComment == comment {
                    editField(comment)
                } else {
                    Text(comment.comment_text ?? "")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func editField(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Edit comment…", text: $editText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                )

            HStack(spacing: 14) {
                Button("Cancel") {
                    editingComment = nil
                }
                .font(.callout)
                .foregroundStyle(.secondary)
                Spacer()
                Button("Save") {
                    saveEdit(comment)
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color.appButtonGradient)
                .disabled(editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func avatar(for comment: Comment) -> some View {
        let name = comment.comment_employee_relation?.employee_name ?? ""
        let initial = name.isEmpty ? "?" : String(name.prefix(1)).uppercased()
        return Text(initial)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(avatarColor(for: name), in: Circle())
    }

    private func avatarColor(for name: String) -> Color {
        let palette: [Color] = [.red, .orange, .green, .blue, .purple, .pink, .teal, .indigo]
        let sum = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[sum % palette.count]
    }

    private func addComment() {
        bugViewModel.addComment(bug: bug, text: commentText)
        commentText = ""
        reload()
    }

    private func saveEdit(_ comment: Comment) {
        bugViewModel.editComment(comment, text: editText)
        editingComment = nil
        reload()
    }

    private func deleteComment(_ comment: Comment) {
        bugViewModel.deleteComment(comment)
        reload()
    }

    private func reload() {
        comments = bugViewModel.comments(for: bug)
    }
}

#Preview {
    NavigationStack {
        CommentSectionView(bug: Bug())
            .environment(BugViewModel())
    }
}