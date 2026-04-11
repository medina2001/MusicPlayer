//
//  AlbumLookupDTO.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

struct iTunesLookupResponse: Decodable {
    let resultCount: Int
    let results: [AlbumLookupItemDTO]
}

struct AlbumLookupItemDTO: Decodable {
    let wrapperType: String?
    let kind: String?
    let collectionId: Int?
    let trackId: Int?
    let collectionName: String?
    let trackName: String?
    let artistName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let trackNumber: Int?
}

extension AlbumLookupItemDTO {
    func toSongDomain() -> Song? {
        guard let id = trackId, let title = trackName else { return nil }
        return Song(
            id: id,
            title: title,
            artist: artistName ?? "Unknown Artist",
            album: collectionName ?? "Unknown Album",
            artworkURL: artworkUrl100.flatMap(URL.init),
            previewURL: previewUrl.flatMap(URL.init),
            duration: TimeInterval(trackTimeMillis ?? 0) / 1000,
            collectionId: collectionId ?? 0
        )
    }
}

extension iTunesLookupResponse {
    func toAlbumDomain() -> Album? {
        guard let collectionItem = results.first(where: { $0.wrapperType == "collection" }),
              let albumId = collectionItem.collectionId,
              let albumTitle = collectionItem.collectionName,
              let albumArtist = collectionItem.artistName
        else { return nil }

        let songs = results
            .filter { $0.kind == "song" }
            .sorted { ($0.trackNumber ?? 0) < ($1.trackNumber ?? 0) }
            .compactMap { $0.toSongDomain() }

        return Album(
            id: albumId,
            title: albumTitle,
            artist: albumArtist,
            artworkURL: collectionItem.artworkUrl100.flatMap(URL.init),
            songs: songs
        )
    }
}
