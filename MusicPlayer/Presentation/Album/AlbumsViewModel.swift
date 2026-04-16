//
//  AlbumsViewModel.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Observation

@Observable
@MainActor
final class AlbumsViewModel {
    private let albumsRepository: AlbumsRepository
    private let connectivityService: ConnectivityMonitoring

    private(set) var viewState: ViewState<Album> = .idle
    private var loadedCollectionId: Int?

    init(albumsRepository: AlbumsRepository, connectivityService: ConnectivityMonitoring) {
        self.albumsRepository = albumsRepository
        self.connectivityService = connectivityService
    }

    func fetchAlbumIfNeeded(collectionId: Int) async {
        guard loadedCollectionId != collectionId else { return }
        await fetchAlbum(collectionId: collectionId)
    }

    func fetchAlbum(collectionId: Int) async {
        guard connectivityService.isConnected else {
            viewState = .error(.networkUnavailable)
            return
        }
        viewState = .loading
        do {
            let album = try await albumsRepository.fetchAlbum(collectionId: collectionId)
            loadedCollectionId = collectionId
            viewState = .loaded(album)
        } catch let error as AppError {
            viewState = .error(error)
        } catch {
            viewState = .error(.networkUnavailable)
        }
    }

    func retryFetch(collectionId: Int) async {
        loadedCollectionId = nil
        await fetchAlbum(collectionId: collectionId)
    }
}
