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
            
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
                .frame(width: 12, height: 12)
                .onTapGesture {
                    displayAlbumSheet()
                    print("Should display Action Sheet")
                }
        }
    }
}
