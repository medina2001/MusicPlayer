//
//  MoreOptionsSheet.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct MoreOptionsSheet: View {
    let song: Song
    let onViewAlbum: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                MoreOptionsSongInfoSection(song: song)
                Divider()
                MoreOptionsActionButton(
                    title: "View Album",
                    systemImage: "square.stack",
                    action: handleViewAlbum
                )
                Spacer()
            }
            .padding(24)
            .navigationTitle("More Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func handleViewAlbum() {
        dismiss()
        onViewAlbum()
    }
}

private struct MoreOptionsSongInfoSection: View {
    let song: Song

    var body: some View {
        HStack(spacing: 16) {
            ArtworkImage(artworkURL: song.artworkURL)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

private struct MoreOptionsActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(16)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel(title)
    }
}
