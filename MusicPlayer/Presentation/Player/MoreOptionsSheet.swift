//
//  MoreOptionsSheet.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct MoreOptionsSheet: View {
    let song: Song

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToAlbum = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                songInfo
                Divider()
                viewAlbumButton
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
        .navigationDestination(isPresented: $navigateToAlbum) {
            // AlbumView will be implemented in task 14
            Text("Album \(song.collectionId)")
        }
    }

    // MARK: - Song Info

    private var songInfo: some View {
        HStack(spacing: 16) {
            artworkThumbnail
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

    private var artworkThumbnail: some View {
        Group {
            if let url = song.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholderArtwork
                    }
                }
            } else {
                placeholderArtwork
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.secondary.opacity(0.2))
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            )
    }

    // MARK: - View Album Button

    private var viewAlbumButton: some View {
        Button {
            dismiss()
            // Navigation to AlbumView is handled by the parent NavigationStack
            // via a NavigationLink or programmatic push in task 14
        } label: {
            HStack {
                Image(systemName: "square.stack")
                Text("View Album")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .font(.body)
            .foregroundStyle(.primary)
            .padding(16)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("View album")
    }
}
