//
//  AlbumsRepository.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

protocol AlbumsRepository {
    func fetchAlbum(collectionId: Int) async throws -> Album
}
