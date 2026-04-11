//
//  Album.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

struct Album: Identifiable, Equatable {
    let id: Int                  // collectionId
    let title: String            // collectionName
    let artist: String           // artistName
    let artworkURL: URL?
    let songs: [Song]
}
