//
//  SongRow.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 16/04/26.
//

import SwiftUI

struct SongRow: View {
    let song: Song
    let displayAlbumSheet: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            ArtworkImage(artworkURL: song.artworkURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: displayAlbumSheet) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View album options")
        }
    }
}
