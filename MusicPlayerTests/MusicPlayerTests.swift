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
    @Test func givenPlayerQueue_whenSelectingSong_thenKeepsQueueOrder() {
        let firstSong = makeSong(id: 1)
        let secondSong = makeSong(id: 2)
        let thirdSong = makeSong(id: 3)

        let context = PlayerContext(song: secondSong, queue: [firstSong, secondSong, thirdSong])

        #expect(context.currentSong == secondSong)
        #expect(context.hasPreviousSong)
        #expect(context.hasNextSong)
    }

    @Test func givenPlayerQueue_whenMovingBetweenSongs_thenUpdatesCurrentSong() {
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

    @Test func givenRecentSongs_whenLoadingRecentSongs_thenShowsLoadedState() async {
        let songsRepository = SongsRepositoryMock()
        let recentSongsRepository = RecentSongsRepositoryMock()
        let connectivityService = ConnectivityServiceMock(isConnected: true)
        let expectedSongs = [makeSong(id: 1), makeSong(id: 2)]
        recentSongsRepository.recentSongsToReturn = expectedSongs
        let viewModel = SongsViewModel(
            songsRepository: songsRepository,
            recentSongsRepository: recentSongsRepository,
            connectivityService: connectivityService
        )

        await viewModel.loadRecentSongs()

        #expect(viewModel.visibleSongs == expectedSongs)
    }

    @Test func givenNoInternet_whenSearchingSongs_thenShowsNetworkError() async {
        let viewModel = SongsViewModel(
            songsRepository: SongsRepositoryMock(),
            recentSongsRepository: RecentSongsRepositoryMock(),
            connectivityService: ConnectivityServiceMock(isConnected: false)
        )

        await viewModel.search(term: "Daft Punk")

        #expect(viewModel.viewState == .error(.networkUnavailable))
    }

    @Test func givenInternet_whenTryingAgainWithSearchText_thenLoadsSearchResults() async {
        let songsRepository = SongsRepositoryMock()
        let expectedSongs = [makeSong(id: 7)]
        songsRepository.songsToReturn = expectedSongs
        let viewModel = SongsViewModel(
            songsRepository: songsRepository,
            recentSongsRepository: RecentSongsRepositoryMock(),
            connectivityService: ConnectivityServiceMock(isConnected: true)
        )
        viewModel.searchText = "Daft Punk"

        await viewModel.tryAgain()

        #expect(viewModel.visibleSongs == expectedSongs)
        #expect(songsRepository.receivedTerms == ["Daft Punk"])
    }

    @Test func givenNoInternet_whenFetchingAlbum_thenShowsNetworkError() async {
        let viewModel = AlbumsViewModel(
            albumsRepository: AlbumsRepositoryMock(),
            connectivityService: ConnectivityServiceMock(isConnected: false)
        )

        await viewModel.fetchAlbum(collectionId: 42)

        #expect(viewModel.viewState == .error(.networkUnavailable))
    }

    @Test func givenAlbumResponse_whenFetchingAlbum_thenShowsLoadedAlbum() async {
        let albumsRepository = AlbumsRepositoryMock()
        let expectedAlbum = makeAlbum(id: 88, songs: [makeSong(id: 1), makeSong(id: 2)])
        albumsRepository.albumToReturn = expectedAlbum
        let viewModel = AlbumsViewModel(
            albumsRepository: albumsRepository,
            connectivityService: ConnectivityServiceMock(isConnected: true)
        )

        await viewModel.fetchAlbum(collectionId: 88)

        #expect(viewModel.viewState == .loaded(expectedAlbum))
    }

    @Test func givenNoInternet_whenPlayingSong_thenPlaybackStaysUnavailable() async {
        let player = PlayerServiceMock()
        let recentSongsRepository = RecentSongsRepositoryMock()
        let connectivityService = ConnectivityServiceMock(isConnected: false)
        let currentSong = makeSong(id: 1)
        let viewModel = PlayerViewModel(
            player: player,
            recentSongsRepository: recentSongsRepository,
            playerContext: PlayerContext(song: currentSong, queue: [currentSong]),
            connectivityService: connectivityService
        )

        await viewModel.playCurrentSong()
        viewModel.togglePlayPause()

        #expect(player.loadedURLs.isEmpty)
        #expect(player.playCallCount == 0)
        #expect(viewModel.isPlaybackAvailable == false)
    }

    @Test func givenReplayEnabled_whenSongFinishes_thenSeeksToStartAndPlaysAgain() {
        let player = PlayerServiceMock()
        player.state = .finished
        let currentSong = makeSong(id: 1)
        let viewModel = PlayerViewModel(
            player: player,
            recentSongsRepository: RecentSongsRepositoryMock(),
            playerContext: PlayerContext(song: currentSong, queue: [currentSong]),
            connectivityService: ConnectivityServiceMock(isConnected: true)
        )
        viewModel.replayCurrentSong = true

        viewModel.handlePlayerStateChange()

        #expect(player.seekTimes == [0])
        #expect(player.playCallCount == 1)
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

    private func makeAlbum(id: Int, songs: [Song]) -> Album {
        Album(
            id: id,
            title: "Album \(id)",
            artist: "Artist \(id)",
            artworkURL: nil,
            songs: songs
        )
    }
}
