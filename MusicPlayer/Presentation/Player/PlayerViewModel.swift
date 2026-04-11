//
//  PlayerViewModel.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class PlayerViewModel {
    private let player: PlayerService
    private let recentSongsRepository: RecentSongsRepository

    var song: Song?
    var showMoreOptions: Bool = false

    var playerState: PlayerState { player.state }
    var currentTime: TimeInterval { player.currentTime }
    var duration: TimeInterval { player.duration }

    init(player: PlayerService, recentSongsRepository: RecentSongsRepository) {
        self.player = player
        self.recentSongsRepository = recentSongsRepository
    }

    func onAppear(song: Song) async {
        self.song = song
        guard let url = song.previewURL else { return }
        player.load(url: url)
        player.play()
        try? await recentSongsRepository.save(song: song)
    }

    func onDisappear() {
        player.release()
    }

    func togglePlayPause() {
        if case .playing = playerState {
            player.pause()
        } else {
            player.play()
        }
    }

    func seek(to time: TimeInterval) {
        player.seek(to: time)
    }

    func seekForward() {
        player.seekForward(by: 15)
    }

    func seekBackward() {
        player.seekBackward(by: 15)
    }
}
