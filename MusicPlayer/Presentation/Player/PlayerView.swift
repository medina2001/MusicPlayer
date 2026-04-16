//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct PlayerView: View {
    let container: DependencyContainer
    let router: AppRouter
    let playerContext: PlayerContext

    @State private var viewModel: PlayerViewModel
    @State private var isShowingMoreOptions = false
    @State private var albumRoute: AlbumRoute?

    init(container: DependencyContainer, router: AppRouter, playerContext: PlayerContext) {
        self.container = container
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
        .navigationDestination(item: $albumRoute) { route in
            AlbumView(
                collectionId: route.collectionId,
                container: container
            ) { song, queue in
                router.presentPlayer(song: song, queue: queue)
                albumRoute = nil
            }
        }
        .task(id: playerContext.currentSong.id) {
            await viewModel.playCurrentSong()
        }
        .onChange(of: viewModel.playerState) {
            viewModel.handlePlayerStateChange()
        }
        .onDisappear(perform: viewModel.onDisappear)
        .navigationTitle(viewModel.albumTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func presentAlbum() {
        albumRoute = AlbumRoute(collectionId: viewModel.currentSong.collectionId)
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
                .padding(.top, 112)

            Spacer()
            
            PlayerInfoSection(viewModel: viewModel)
                .padding(.top, 44)
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
            .padding(.top, 28)
            .padding(.horizontal, 24)

            if case .error(let error) = viewModel.playerState {
                PlayerErrorBanner(error: error, retry: viewModel.retry)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    @Bindable var viewModel: PlayerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.currentSong.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                Text(viewModel.currentSong.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Button(action: viewModel.toggleReplayCurrentSong) {
                    Image(systemName: "repeat")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(viewModel.replayCurrentSong ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(viewModel.replayCurrentSong ? "Disable replay" : "Enable replay")
            }
        }
    }
}

private struct PlayerSeekSection: View {
    let currentTime: TimeInterval
    let duration: TimeInterval
    @Binding var isEditingSlider: Bool
    let onSeek: (TimeInterval) -> Void

    var body: some View {
        VStack(spacing: 8) {
            PlayerProgressBar(
                progress: duration > 0 ? currentTime / duration : 0,
                isEditing: $isEditingSlider
            ) { progress in
                onSeek(progress * duration)
            }
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
        HStack(spacing: 36) {
            Button(action: onPrevious) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .disabled(!canPlayPreviousSong)
            .accessibilityLabel("Previous song")

            playPauseButton
            .disabled(isLoading)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            Button(action: onNext) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .disabled(!canPlayNextSong)
            .accessibilityLabel("Next song")
        }
    }

    @ViewBuilder
    private var playPauseButton: some View {
        if #available(iOS 26, *) {
            Button(action: onPlayPause) {
                playPauseContent
                    .frame(width: 56, height: 56)
            }
            .buttonStyle(.glassProminent)
        } else {
            Button(action: onPlayPause) {
                playPauseContent
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var playPauseContent: some View {
        switch playerState {
        case .loading:
            ProgressView()
                .tint(.primary)
        case .playing:
            Image(systemName: "pause.fill")
                .font(.title2)
                .foregroundStyle(.primary)
        default:
            Image(systemName: "play.fill")
                .font(.title2)
                .foregroundStyle(.primary)
                .padding(.leading, 2)
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

private struct PlayerProgressBar: View {
    let progress: Double
    @Binding var isEditing: Bool
    let onSeek: (Double) -> Void

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = min(max(progress, 0), 1)
            let width = proxy.size.width
            let thumbOffset = max(0, min(width, width * clampedProgress))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.25))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: thumbOffset, height: 4)

                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)
                    .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                    .offset(x: max(0, thumbOffset - 9))
            }
            .frame(height: 18)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isEditing = true
                        let nextProgress = value.location.x / max(width, 1)
                        onSeek(min(max(nextProgress, 0), 1))
                    }
                    .onEnded { value in
                        let nextProgress = value.location.x / max(width, 1)
                        onSeek(min(max(nextProgress, 0), 1))
                        isEditing = false
                    }
            )
        }
        .frame(height: 18)
    }
}
