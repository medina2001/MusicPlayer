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

    private(set) var viewState: ViewState<Album> = .loading

    init(albumsRepository: AlbumsRepository) {
        self.albumsRepository = albumsRepository
    }

    func fetchAlbum(collectionId: Int) async {
        viewState = .loading
        do {
            let album = try await albumsRepository.fetchAlbum(collectionId: collectionId)
            viewState = .loaded(album)
        } catch let error as AppError {
            viewState = .error(error)
        } catch {
            viewState = .error(.networkUnavailable)
        }
    }

    func retryFetch(collectionId: Int) async {
        viewState = .loading
        await fetchAlbum(collectionId: collectionId)
    }
}
