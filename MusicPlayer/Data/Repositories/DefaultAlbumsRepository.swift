//
//  DefaultAlbumsRepository.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

final class DefaultAlbumsRepository: AlbumsRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchAlbum(collectionId: Int) async throws -> Album {
        let endpoint = iTunesEndpoint.lookup(collectionId: collectionId)
        let response: iTunesLookupResponse = try await apiClient.execute(endpoint)
        guard let album = response.toAlbumDomain() else {
            throw AppError.decodingFailure
        }
        return album
    }
}
