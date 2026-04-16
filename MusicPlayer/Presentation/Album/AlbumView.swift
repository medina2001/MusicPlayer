//
//  AlbumView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct AlbumView: View {
    let collectionId: Int
    let onSelectSong: (Song, [Song]) -> Void

    @State private var viewModel: AlbumsViewModel

    init(
        collectionId: Int,
        container: DependencyContainer,
        onSelectSong: @escaping (Song, [Song]) -> Void
    ) {
        self.collectionId = collectionId
        self.onSelectSong = onSelectSong
        _viewModel = State(initialValue: container.makeAlbumsViewModel())
    }

    var body: some View {
        AlbumContentView(
            viewModel: viewModel,
            collectionId: collectionId,
            onSelectSong: onSelectSong
        )
    }
}

private struct AlbumContentView: View {
    @Bindable var viewModel: AlbumsViewModel

    let collectionId: Int
    let onSelectSong: (Song, [Song]) -> Void

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let album):
                if album.songs.isEmpty {
                    AlbumEmptyStateView(album: album)
                } else {
                    albumDetailView(album: album)
                }
            case .error(let error):
                AlbumErrorStateView(error: error) {
                    Task { await viewModel.retryFetch(collectionId: collectionId) }
                }
            }
        }
        .task {
            await viewModel.fetchAlbumIfNeeded(collectionId: collectionId)
        }
    }

    private func albumDetailView(album: Album) -> some View {
        List {
            Section {
                AlbumHeaderView(album: album)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)

            Section {
                ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                    Button {
                        onSelectSong(song, album.songs)
                    } label: {
                        AlbumSongRow(trackNumber: index + 1, song: song)
                            .accessibilityLabel("Track \(index + 1), \(song.title) by \(song.artist)")
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct AlbumHeaderView: View {
    let album: Album

    var body: some View {
        VStack(spacing: 12) {
            AlbumArtworkView(artworkURL: album.artworkURL)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 12)
                .accessibilityLabel(album.title)

            VStack(spacing: 4) {
                Text(album.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

private struct AlbumArtworkView: View {
    let artworkURL: URL?

    var body: some View {
        Group {
            if let artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        placeholderArtwork
                    }
                }
            } else {
                placeholderArtwork
            }
        }
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.2))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            )
    }
}

private struct AlbumSongRow: View {
    let trackNumber: Int
    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            Text("\(trackNumber)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(formattedDuration)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var formattedDuration: String {
        let total = max(0, Int(song.duration))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct AlbumEmptyStateView: View {
    let album: Album

    var body: some View {
        VStack(spacing: 16) {
            AlbumArtworkView(artworkURL: album.artworkURL)
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8)
                .accessibilityLabel(album.title)

            ContentUnavailableView(
                "No Tracks",
                systemImage: "music.note.list",
                description: Text("No songs found for this album.")
            )
        }
    }
}

private struct AlbumErrorStateView: View {
    let error: AppError
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "square.stack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("Couldn't Load Album")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button(action: retry) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
