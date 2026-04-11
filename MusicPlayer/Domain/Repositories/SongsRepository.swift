//
//  SongsRepository.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

protocol SongsRepository {
    func fetchSongs(term: String, limit: Int, offset: Int) async throws -> [Song]
}
