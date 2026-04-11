//
//  RecentSongRecord.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation
import SwiftData

@Model
final class RecentSongRecord {
    @Attribute(.unique) var songId: Int
    var title: String
    var artist: String
    var album: String
    var artworkURLString: String?
    var previewURLString: String?
    var duration: TimeInterval
    var collectionId: Int
    var playedAt: Date

    init(song: Song, playedAt: Date = .now) {
        self.songId = song.id
        self.title = song.title
        self.artist = song.artist
        self.album = song.album
        self.artworkURLString = song.artworkURL?.absoluteString
        self.previewURLString = song.previewURL?.absoluteString
        self.duration = song.duration
        self.collectionId = song.collectionId
        self.playedAt = playedAt
    }

    func toDomain() -> Song {
        Song(
            id: songId,
            title: title,
            artist: artist,
            album: album,
            artworkURL: artworkURLString.flatMap(URL.init),
            previewURL: previewURLString.flatMap(URL.init),
            duration: duration,
            collectionId: collectionId
        )
    }
}
