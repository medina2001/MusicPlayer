//
//  DependencyContainer.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class DependencyContainer {
    let apiClient: APIClient
    let songsRepository: SongsRepository
    let albumsRepository: AlbumsRepository
    let recentSongsRepository: RecentSongsRepository
    let playerService: PlayerService
    let connectivityService: ConnectivityMonitoring

    init(modelContext: ModelContext) {
        apiClient = URLSessionAPIClient()
        songsRepository = DefaultSongsRepository(apiClient: apiClient)
        albumsRepository = DefaultAlbumsRepository(apiClient: apiClient)
        recentSongsRepository = DefaultRecentSongsRepository(context: modelContext)
        playerService = AVPlayerService()
        connectivityService = ConnectivityService()
    }

    init(
        apiClient: APIClient,
        songsRepository: SongsRepository,
        albumsRepository: AlbumsRepository,
        recentSongsRepository: RecentSongsRepository,
        playerService: PlayerService,
        connectivityService: ConnectivityMonitoring
    ) {
        self.apiClient = apiClient
        self.songsRepository = songsRepository
        self.albumsRepository = albumsRepository
        self.recentSongsRepository = recentSongsRepository
        self.playerService = playerService
        self.connectivityService = connectivityService
    }

    func makeSongsViewModel() -> SongsViewModel {
        SongsViewModel(
            songsRepository: songsRepository,
            recentSongsRepository: recentSongsRepository,
            connectivityService: connectivityService
        )
    }

    func makeAlbumsViewModel() -> AlbumsViewModel {
        AlbumsViewModel(
            albumsRepository: albumsRepository,
            connectivityService: connectivityService
        )
    }

    func makePlayerViewModel(playerContext: PlayerContext) -> PlayerViewModel {
        PlayerViewModel(
            player: playerService,
            recentSongsRepository: recentSongsRepository,
            playerContext: playerContext,
            connectivityService: connectivityService
        )
    }
}
