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
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 10)

            MoreOptionsSongInfoSection(song: song)

            MoreOptionsActionButton(
                title: "View album",
                systemImage: "music.note",
                action: handleViewAlbum
            )
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 24)
        .presentationDetents([.height(170)])
        .presentationDragIndicator(.hidden)
    }

    private func handleViewAlbum() {
        dismiss()
        DispatchQueue.main.async {
            onViewAlbum()
        }
    }
}

private struct MoreOptionsSongInfoSection: View {
    let song: Song

    var body: some View {
        VStack(spacing: 6) {
            Text(song.title)
                .font(.headline)
                .lineLimit(1)
            Text(song.artist)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
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
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel(title)
    }
}
