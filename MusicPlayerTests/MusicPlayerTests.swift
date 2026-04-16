//
//  MusicPlayerTests.swift
//  MusicPlayerTests
//
//  Created by Gabriel Maciel on 10/04/26.
//

import Foundation
import Testing
@testable import MusicPlayer

@MainActor
struct MusicPlayerTests {
    @Test func playerContextKeepsSelectedSongInQueueOrder() {
        let firstSong = makeSong(id: 1)
        let secondSong = makeSong(id: 2)
        let thirdSong = makeSong(id: 3)

        let context = PlayerContext(song: secondSong, queue: [firstSong, secondSong, thirdSong])

        #expect(context.currentSong == secondSong)
        #expect(context.hasPreviousSong)
        #expect(context.hasNextSong)
    }

    @Test func playerContextNavigatesBetweenSongs() {
        let firstSong = makeSong(id: 1)
        let secondSong = makeSong(id: 2)

        let context = PlayerContext(song: firstSong, queue: [firstSong, secondSong])

        let nextSong = context.goToNextSong()
        #expect(nextSong == secondSong)
        #expect(context.currentSong == secondSong)

        let previousSong = context.goToPreviousSong()
        #expect(previousSong == firstSong)
        #expect(context.currentSong == firstSong)
    }

    @Test func appRouterReusesExistingPlayerContext() {
        let firstSong = makeSong(id: 1)
        let secondSong = makeSong(id: 2, collectionId: 200)
        let router = AppRouter()

        router.presentPlayer(song: firstSong, queue: [firstSong])
        let firstContextID = try #require(router.playerContext?.id)

        router.presentPlayer(song: secondSong, queue: [firstSong, secondSong])

        #expect(router.playerContext?.id == firstContextID)
        #expect(router.playerContext?.currentSong == secondSong)
    }

    private func makeSong(id: Int, collectionId: Int = 100) -> Song {
        Song(
            id: id,
            title: "Song \(id)",
            artist: "Artist",
            album: "Album",
            artworkURL: nil,
            previewURL: URL(string: "https://example.com/\(id).m4a"),
            duration: 30,
            collectionId: collectionId
        )
    }
}
