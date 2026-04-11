//
//  AppError.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

enum AppError: LocalizedError {
    case networkUnavailable
    case httpError(statusCode: Int)
    case decodingFailure
    case persistenceFailure
    case playbackFailure

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network and try again."
        case .httpError(let code):
            return "Server error (HTTP \(code)). Please try again later."
        case .decodingFailure:
            return "Could not read server response. Please try again."
        case .persistenceFailure:
            return "Could not save data locally."
        case .playbackFailure:
            return "Playback failed. The preview may be unavailable."
        }
    }
}
