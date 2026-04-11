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

    init(modelContext: ModelContext) {
        apiClient = URLSessionAPIClient()
        songsRepository = DefaultSongsRepository(apiClient: apiClient)
        albumsRepository = DefaultAlbumsRepository(apiClient: apiClient)
        recentSongsRepository = DefaultRecentSongsRepository(context: modelContext)
        playerService = AVPlayerService()
    }

    func makeSongsViewModel() -> SongsViewModel {
        SongsViewModel(
            songsRepository: songsRepository,
            recentSongsRepository: recentSongsRepository
        )
    }
}
