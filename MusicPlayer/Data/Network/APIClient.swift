//
//  APIClient.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

protocol APIClient {
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
