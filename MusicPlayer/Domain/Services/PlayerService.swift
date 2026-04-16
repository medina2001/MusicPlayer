//
//  PlayerService.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation

enum PlayerState {
    case idle
    case loading
    case playing
    case paused
    case finished
    case error(AppError)
}

protocol PlayerService: AnyObject {
    var state: PlayerState { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }

    func load(url: URL)
    func play()
    func pause()
    func seek(to time: TimeInterval)
    func release()
}
