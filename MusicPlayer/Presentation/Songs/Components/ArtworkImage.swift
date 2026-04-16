//
//  Artworkswift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 16/04/26.
//

import SwiftUI

struct ArtworkImage: View {
    let artworkURL: URL?
    
    var body: some View {
        Group {
            if let url = artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    placeholderArtwork
                }
            } else {
                placeholderArtwork
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 8)
            .redacted(reason: .placeholder)
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            )
    }
}
