//
//  DefaultSongsRepository.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

final class DefaultSongsRepository: SongsRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        let endpoint = iTunesEndpoint.search(term: term, limit: limit, offset: offset)
        let response: iTunesSearchResponse = try await apiClient.execute(endpoint)
        return response.results.compactMap { $0.toDomain() }
    }
}
