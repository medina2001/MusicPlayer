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
    private let playerContext: PlayerContext

    private(set) var currentSong: Song
    var replayCurrentSong = false

    var playerState: PlayerState { player.state }
    var currentTime: TimeInterval { player.currentTime }
    var duration: TimeInterval { player.duration }
    var canPlayPreviousSong: Bool { playerContext.hasPreviousSong }
    var canPlayNextSong: Bool { playerContext.hasNextSong }
    var albumTitle: String { currentSong.album }

    init(
        player: PlayerService,
        recentSongsRepository: RecentSongsRepository,
        playerContext: PlayerContext
    ) {
        self.player = player
        self.recentSongsRepository = recentSongsRepository
        self.playerContext = playerContext
        self.currentSong = playerContext.currentSong
    }

    func playCurrentSong() async {
        currentSong = playerContext.currentSong
        await loadAndPlay(song: currentSong)
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

    func playNextSong() {
        guard let nextSong = playerContext.goToNextSong() else { return }
        currentSong = nextSong
        Task { await loadAndPlay(song: nextSong) }
    }

    func playPreviousSong() {
        guard let previousSong = playerContext.goToPreviousSong() else { return }
        currentSong = previousSong
        Task { await loadAndPlay(song: previousSong) }
    }

    func retry() {
        Task { await loadAndPlay(song: currentSong) }
    }

    func toggleReplayCurrentSong() {
        replayCurrentSong.toggle()
    }

    func handlePlayerStateChange() {
        guard replayCurrentSong else { return }
        guard case .finished = playerState else { return }
        player.seek(to: 0)
        player.play()
    }

    private func loadAndPlay(song: Song) async {
        guard let url = song.previewURL else { return }
        player.load(url: url)
        player.play()
        try? await recentSongsRepository.save(song: song)
    }
}
