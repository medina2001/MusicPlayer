//
//  PlayerContext.swift
//  MusicPlayer
//
//  Created by Codex on 16/04/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class PlayerContext: Identifiable, Hashable {
    let id = UUID()

    private(set) var queue: [Song]
    private(set) var currentIndex: Int

    var currentSong: Song {
        queue[currentIndex]
    }

    var hasPreviousSong: Bool {
        currentIndex > 0
    }

    var hasNextSong: Bool {
        currentIndex < queue.count - 1
    }

    init(song: Song, queue: [Song]) {
        let normalizedQueue = queue.isEmpty ? [song] : queue
        self.queue = normalizedQueue
        self.currentIndex = normalizedQueue.firstIndex(of: song) ?? 0
    }

    func update(song: Song, queue: [Song]) {
        let normalizedQueue = queue.isEmpty ? [song] : queue
        self.queue = normalizedQueue
        self.currentIndex = normalizedQueue.firstIndex(of: song) ?? 0
    }

    func goToNextSong() -> Song? {
        guard hasNextSong else { return nil }
        currentIndex += 1
        return currentSong
    }

    func goToPreviousSong() -> Song? {
        guard hasPreviousSong else { return nil }
        currentIndex -= 1
        return currentSong
    }

    static func == (lhs: PlayerContext, rhs: PlayerContext) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
