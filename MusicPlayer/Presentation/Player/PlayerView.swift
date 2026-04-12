//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct PlayerView: View {
    let song: Song

    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: PlayerViewModel?

    var body: some View {
        Group {
            if let viewModel {
                PlayerContentView(viewModel: viewModel)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(LinearGradient.appBackground.ignoresSafeArea())
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = container.makePlayerViewModel()
            }
        }
        .task(id: song.id) {
            guard let viewModel else { return }
            await viewModel.onAppear(song: song)
        }
        .onDisappear {
            viewModel?.onDisappear()
        }
    }
}

// MARK: - Content View

private struct PlayerContentView: View {
    let viewModel: PlayerViewModel
    @State private var isEditingSlider = false

    var body: some View {
        ZStack {
            LinearGradient.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                artworkSection
                    .padding(.top, 24)

                infoSection
                    .padding(.top, 32)
                    .padding(.horizontal, 24)

                seekSection
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                controlsSection
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                if case .error(let error) = viewModel.playerState {
                    errorBanner(error)
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                }

                Spacer()

                moreOptionsButton
                    .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: Bindable(viewModel).showMoreOptions) {
            if let song = viewModel.song {
                MoreOptionsSheet(song: song)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Artwork

    private var artworkSection: some View {
        Group {
            if let url = viewModel.song?.artworkURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        placeholderArtwork
                    }
                }
            } else {
                placeholderArtwork
            }
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 20)
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary.opacity(0.2))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
            )
    }

    // MARK: - Info

    private var infoSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.song?.title ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(viewModel.song?.artist ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }

    // MARK: - Seek

    private var seekSection: some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { viewModel.duration > 0 ? viewModel.currentTime / viewModel.duration : 0 },
                    set: { newValue in
                        if isEditingSlider {
                            viewModel.seek(to: newValue * viewModel.duration)
                        }
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    isEditingSlider = editing
                    if !editing {
                        // final seek already applied via set closure above
                    }
                }
            )
            .accessibilityLabel("Seek")
            .accessibilityValue("\(formattedTime(viewModel.currentTime)) of \(formattedTime(viewModel.duration))")

            HStack {
                Text(formattedTime(viewModel.currentTime))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(formattedTime(viewModel.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 40) {
            Button {
                viewModel.seekBackward()
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Seek backward 15 seconds")

            playPauseButton

            Button {
                viewModel.seekForward()
            } label: {
                Image(systemName: "goforward.15")
                    .font(.title)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Seek forward 15 seconds")
        }
    }

    private var playPauseButton: some View {
        Button {
            viewModel.togglePlayPause()
        } label: {
            Group {
                switch viewModel.playerState {
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
        .accessibilityLabel(playPauseAccessibilityLabel)
        .disabled({
            if case .loading = viewModel.playerState { return true }
            return false
        }())
    }

    private var playPauseAccessibilityLabel: String {
        if case .playing = viewModel.playerState { return "Pause" }
        return "Play"
    }

    // MARK: - Error Banner

    private func errorBanner(_ error: AppError) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - More Options

    private var moreOptionsButton: some View {
        Button {
            viewModel.showMoreOptions = true
        } label: {
            Label("More options", systemImage: "ellipsis.circle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel("More options")
    }

    // MARK: - Helpers

    private func formattedTime(_ time: TimeInterval) -> String {
        let total = max(0, Int(time))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
