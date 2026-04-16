//
//  URLSessionAPIClient.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.urlRequest()
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw AppError.networkUnavailable
            }
            guard (200...299).contains(http.statusCode) else {
                throw AppError.httpError
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AppError.decodingFailure
            }
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkUnavailable
        }
    }
}
