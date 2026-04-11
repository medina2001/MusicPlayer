//
//  Song.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

struct Song: Identifiable, Equatable, Hashable {
    let id: Int                  // trackId from iTunes
    let title: String            // trackName
    let artist: String           // artistName
    let album: String            // collectionName
    let artworkURL: URL?         // artworkUrl100
    let previewURL: URL?         // previewUrl
    let duration: TimeInterval   // trackTimeMillis / 1000
    let collectionId: Int        // collectionId
}
