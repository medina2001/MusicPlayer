//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct PlayerView: View {
    let router: AppRouter
    let playerContext: PlayerContext

    @State private var viewModel: PlayerViewModel
    @State private var isShowingMoreOptions = false

    init(container: DependencyContainer, router: AppRouter, playerContext: PlayerContext) {
        self.router = router
        self.playerContext = playerContext
        _viewModel = State(
            initialValue: container.makePlayerViewModel(playerContext: playerContext)
        )
    }

    var body: some View {
        PlayerContentView(
            viewModel: viewModel,
            isShowingMoreOptions: $isShowingMoreOptions,
            onViewAlbum: presentAlbum
        )
        .task(id: playerContext.currentSong.id) {
            await viewModel.playCurrentSong()
        }
        .onDisappear(perform: viewModel.onDisappear)
    }

    private func presentAlbum() {
        router.presentAlbum(for: viewModel.currentSong)
    }
}

private struct PlayerContentView: View {
    @Bindable var viewModel: PlayerViewModel
    @Binding var isShowingMoreOptions: Bool

    let onViewAlbum: () -> Void

    @State private var isEditingSlider = false

    var body: some View {
        VStack(spacing: 0) {
            PlayerArtworkSection(song: viewModel.currentSong)
                .padding(.top, 24)

            PlayerInfoSection(song: viewModel.currentSong)
                .padding(.top, 32)
                .padding(.horizontal, 24)

            PlayerSeekSection(
                currentTime: viewModel.currentTime,
                duration: viewModel.duration,
                isEditingSlider: $isEditingSlider,
                onSeek: viewModel.seek(to:)
            )
            .padding(.top, 24)
            .padding(.horizontal, 24)

            PlayerControlsSection(
                playerState: viewModel.playerState,
                canPlayPreviousSong: viewModel.canPlayPreviousSong,
                canPlayNextSong: viewModel.canPlayNextSong,
                onPrevious: viewModel.playPreviousSong,
                onPlayPause: viewModel.togglePlayPause,
                onNext: viewModel.playNextSong
            )
            .padding(.top, 24)
            .padding(.horizontal, 24)

            if case .error(let error) = viewModel.playerState {
                PlayerErrorBanner(error: error, retry: viewModel.retry)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient.appBackground.ignoresSafeArea())
        .sheet(isPresented: $isShowingMoreOptions) {
            MoreOptionsSheet(song: viewModel.currentSong, onViewAlbum: onViewAlbum)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingMoreOptions = true
                } label: {
                    Label("More options", systemImage: "ellipsis.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("More options")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PlayerArtworkSection: View {
    let song: Song

    var body: some View {
        Group {
            if let url = song.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        PlayerPlaceholderView(cornerRadius: 32)
                    }
                }
            } else {
                PlayerPlaceholderView(cornerRadius: 32)
            }
        }
        .frame(width: 264, height: 264)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

private struct PlayerInfoSection: View {
    let song: Song

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

private struct PlayerSeekSection: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    @Binding var isEditingSlider: Bool
    let onSeek: (TimeInterval) -> Void

    var body: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { duration > 0 ? currentTime / duration : 0 },
                    set: { newValue in
                        if isEditingSlider {
                            onSeek(newValue * duration)
                        }
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    isEditingSlider = editing
                }
            )
            .accessibilityLabel("Seek")
            .accessibilityValue("\(formattedTime(currentTime)) of \(formattedTime(duration))")

            HStack {
                Text(formattedTime(currentTime))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formattedTime(duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        guard time.isFinite else { return "0:00" }
        let totalSeconds = max(0, Int(time.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct PlayerControlsSection: View {
    let playerState: PlayerState
    let canPlayPreviousSong: Bool
    let canPlayNextSong: Bool
    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            Button(action: onPrevious) {
                Image(systemName: "backward.end.fill")
                    .font(.title)
                    .foregroundStyle(.primary)
            }
            .disabled(!canPlayPreviousSong)
            .accessibilityLabel("Previous song")

            Button(action: onPlayPause) {
                Group {
                    switch playerState {
                    case .loading:
                        ProgressView()
                            .tint(.primary)
                            .frame(width: 44, height: 44)
                    case .playing:
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.primary)
                    default:
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .disabled(isLoading)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: onNext) {
                Image(systemName: "forward.end.fill")
                    .font(.title)
                    .foregroundStyle(.primary)
            }
            .disabled(!canPlayNextSong)
            .accessibilityLabel("Next song")
        }
    }

    private var isLoading: Bool {
        if case .loading = playerState { return true }
        return false
    }

    private var isPlaying: Bool {
        if case .playing = playerState { return true }
        return false
    }
}

private struct PlayerErrorBanner: View {
    let error: AppError
    let retry: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            Spacer()
            if case .playbackFailure = error {
                Button("Retry", action: retry)
                    .font(.caption.weight(.semibold))
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct PlayerPlaceholderView: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .redacted(reason: .placeholder)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
            )
    }
}
