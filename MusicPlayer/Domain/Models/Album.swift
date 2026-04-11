//
//  Album.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

struct Album: Identifiable, Equatable {
    let id: Int
    let title: String
    let artist: String
    let artworkURL: URL?
    let songs: [Song]
}
