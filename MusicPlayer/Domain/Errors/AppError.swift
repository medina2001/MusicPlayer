//
//  AppError.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    case networkUnavailable
    case httpError
    case decodingFailure
    case persistenceFailure
    case playbackFailure
    case noSongsFound
    case requestCancelled
    case unknownError

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your connection and try again."
        case .httpError:
            return "Something went wrong on our end. Please try again in a moment."
        case .decodingFailure:
            return "We couldn't load the content right now. Please try again."
        case .persistenceFailure:
            return "We couldn't save your data locally."
        case .playbackFailure:
            return "This preview isn't available right now. Please try another song."
        case .noSongsFound:
            return "No songs found. Please try again."
        case .requestCancelled:
            return "The request was cancelled."
        case .unknownError:
            return "Something went wrong. Try again later."
        }
    }
}
