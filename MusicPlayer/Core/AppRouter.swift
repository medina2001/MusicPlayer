//
//  AppRouter.swift
//  MusicPlayer
//
//  Created by Codex on 16/04/26.
//

import Foundation
import Observation

struct AlbumSheetRoute: Identifiable, Equatable {
    let collectionId: Int

    var id: Int { collectionId }
}

@Observable
@MainActor
final class AppRouter {
    var playerContext: PlayerContext?
    var albumSheet: AlbumSheetRoute?

    func presentPlayer(song: Song, queue: [Song]) {
        if let playerContext {
            playerContext.update(song: song, queue: queue)
        } else {
            playerContext = PlayerContext(song: song, queue: queue)
        }
    }

    func dismissPlayer() {
        playerContext = nil
        albumSheet = nil
    }

    func presentAlbum(for song: Song) {
        albumSheet = AlbumSheetRoute(collectionId: song.collectionId)
    }

    func dismissAlbum() {
        albumSheet = nil
    }
}
