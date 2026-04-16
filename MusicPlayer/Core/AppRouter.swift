//
//  AppRouter.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 16/04/26.
//

import Foundation
import Observation

struct AlbumRoute: Identifiable, Equatable, Hashable {
    let collectionId: Int

    var id: Int { collectionId }
}

@Observable
@MainActor
final class AppRouter {
    var playerContext: PlayerContext?
    var albumRoute: AlbumRoute?

    func presentPlayer(song: Song, queue: [Song]) {
        if let playerContext {
            playerContext.update(song: song, queue: queue)
        } else {
            playerContext = PlayerContext(song: song, queue: queue)
        }
    }

    func dismissPlayer() {
        playerContext = nil
        albumRoute = nil
    }

    func presentAlbum(for song: Song) {
        albumRoute = AlbumRoute(collectionId: song.collectionId)
    }

    func dismissAlbum() {
        albumRoute = nil
    }
}
