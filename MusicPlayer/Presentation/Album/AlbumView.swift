//
//  AlbumView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct AlbumView: View {
    let collectionId: Int

    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: AlbumsViewModel?

    var body: some View {
        Group {
            if let viewModel {
                AlbumContentView(viewModel: viewModel, collectionId: collectionId)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = container.makeAlbumsViewModel()
            }
        }
    }
}

// MARK: - Content View

private struct AlbumContentView: View {
    let viewModel: AlbumsViewModel
    let collectionId: Int

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let album):
                if album.songs.isEmpty {
                    emptyStateView(album: album)
                } else {
                    albumDetailView(album: album)
                }
            case .error(let error):
                errorView(error)
            }
        }
        .task {
            await viewModel.fetchAlbum(collectionId: collectionId)
        }
    }

    // MARK: - Album Detail

    private func albumDetailView(album: Album) -> some View {
        List {
            Section {
                albumHeader(album: album)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)

            Section {
                ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                    NavigationLink(value: song) {
                        AlbumSongRow(trackNumber: index + 1, song: song)
                            .accessibilityLabel("Track \(index + 1), \(song.title) by \(song.artist)")
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
    }

    private func albumHeader(album: Album) -> some View {
        VStack(spacing: 12) {
            artworkImage(url: album.artworkURL, title: album.title)
                .frame(width: 200, height: 200)
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

    @ViewBuilder
    private func artworkImage(url: URL?, title: String) -> some View {
        if let url {
            AsyncImage(url: url) { phase in
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

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.2))
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            )
    }

    // MARK: - Empty State

    private func emptyStateView(album: Album) -> some View {
        VStack(spacing: 16) {
            artworkImage(url: album.artworkURL, title: album.title)
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

    // MARK: - Error

    private func errorView(_ error: AppError) -> some View {
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
            Button {
                Task { await viewModel.retryFetch(collectionId: collectionId) }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Album Song Row

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
