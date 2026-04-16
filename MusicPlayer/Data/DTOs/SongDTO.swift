//
//  SongDTO.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

struct iTunesSearchResponse: Decodable {
    let resultCount: Int
    let results: [SongDTO]
}

struct SongDTO: Decodable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let collectionId: Int?
    let wrapperType: String?
    let kind: String?
}

extension SongDTO {
    func toDomain() -> Song? {
        guard let id = trackId, let title = trackName else { return nil }
        return Song(
            id: id,
            title: title,
            artist: artistName ?? "Unknown Artist",
            album: collectionName ?? "Unknown Album",
            artworkURL: URL(string: upscaleArtworkURL(artworkUrl100)),
            previewURL: previewUrl.flatMap(URL.init),
            duration: TimeInterval(trackTimeMillis ?? 0) / 1000,
            collectionId: collectionId ?? 0
        )
    }
    
    func upscaleArtworkURL(_ url: String?) -> String {
        guard let url else { return "" }
        return url.replacingOccurrences(of: "100x100bb.jpg", with: "1440x1440bb.jpg")
    }
}
