//
//  AVPlayerService.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import AVFoundation
import Observation

@Observable
final class AVPlayerService: PlayerService {

    // MARK: - PlayerService conformance

    private(set) var state: PlayerState = .idle
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    // MARK: - Private

    private var player: AVPlayer?
    private var statusObservation: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var endObserver: NSObjectProtocol?

    // MARK: - PlayerService methods

    func load(url: URL) {
        release()
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        state = .loading
        observeStatus(item: item)
        observeTimeUpdates()
        observePlaybackEnd()
    }

    func play() {
        player?.play()
        state = .playing
    }

    func pause() {
        player?.pause()
        state = .paused
    }

    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        let cmTime = CMTime(seconds: clamped, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }

    func release() {
        player?.pause()

        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }

        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }

        statusObservation?.invalidate()
        statusObservation = nil

        player = nil
        state = .idle
        currentTime = 0
        duration = 0
    }

    // MARK: - Private observers

    private func observeStatus(item: AVPlayerItem) {
        statusObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            guard let self else { return }
            switch item.status {
            case .readyToPlay:
                let seconds = item.duration.seconds
                self.duration = seconds.isNaN || seconds.isInfinite ? 0 : seconds
                self.play()
            case .failed:
                self.state = .error(.playbackFailure)
            default:
                break
            }
        }
    }

    private func observeTimeUpdates() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            let seconds = time.seconds
            self.currentTime = seconds.isNaN || seconds.isInfinite ? 0 : seconds
        }
    }

    private func observePlaybackEnd() {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.state = .finished
            self.seek(to: 0)
        }
    }
}
