//
//  iTunesEndpoint.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

enum iTunesEndpoint {
    static let baseURL = URL(string: "https://itunes.apple.com")!

    static func search(term: String, limit: Int, offset: Int) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "/search",
            method: .get,
            queryItems: [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ],
            headers: [:]
        )
    }

    static func lookup(collectionId: Int) -> Endpoint {
        Endpoint(
            baseURL: baseURL,
            path: "/lookup",
            method: .get,
            queryItems: [
                URLQueryItem(name: "id", value: String(collectionId)),
                URLQueryItem(name: "entity", value: "song")
            ],
            headers: [:]
        )
    }
}
