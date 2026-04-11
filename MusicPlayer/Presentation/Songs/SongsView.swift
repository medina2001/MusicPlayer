//
//  SongsView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct SongsView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: SongsViewModel?
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>? = nil

    var body: some View {
        Group {
            if let viewModel {
                SongsContentView(
                    viewModel: viewModel,
                    searchText: $searchText,
                    searchTask: $searchTask
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = container.makeSongsViewModel()
            }
        }
    }
}

// MARK: - Content View

private struct SongsContentView: View {
    let viewModel: SongsViewModel
    @Binding var searchText: String
    @Binding var searchTask: Task<Void, Never>?

    var body: some View {
        mainContent
            .searchable(text: $searchText, prompt: "Search songs")
            .accessibilityLabel("Search songs")
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                if newValue.isEmpty {
                    searchTask = Task {
                        await viewModel.loadRecentSongs()
                    }
                } else {
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        guard !Task.isCancelled else { return }
                        await viewModel.search(term: newValue)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                Task { await viewModel.loadRecentSongs() }
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.viewState {
        case .idle:
            recentSongsList
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let songs):
            if songs.isEmpty {
                emptyStateView
            } else {
                songsList(songs)
            }
        case .error(let error):
            errorView(error)
        }
    }

    private var recentSongsList: some View {
        Group {
            if viewModel.recentSongs.isEmpty {
                ContentUnavailableView(
                    "No Recent Songs",
                    systemImage: "music.note",
                    description: Text("Search for songs to get started.")
                )
            } else {
                List(viewModel.recentSongs) { song in
                    NavigationLink(value: song) {
                        SongRow(song: song)
                    }
                    .accessibilityLabel("\(song.title) by \(song.artist)")
                }
                .navigationDestination(for: Song.self) { song in
                    PlayerView(song: song)
                }
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("No songs found for \"\(searchText)\".")
        )
    }

    private func songsList(_ songs: [Song]) -> some View {
        List {
            ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                NavigationLink(value: song) {
                    SongRow(song: song)
                        .accessibilityLabel("\(song.title) by \(song.artist)")
                }
                .onAppear {
                    if index >= songs.count - 5 && !viewModel.paginationExhausted {
                        Task { await viewModel.loadNextPage() }
                    }
                }
            }
            if viewModel.isLoadingPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .navigationDestination(for: Song.self) { song in
            PlayerView(song: song)
        }
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry") {
                Task { await viewModel.search(term: searchText) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Song Row

struct SongRow: View {
    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            artworkImage
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
    }

    private var artworkImage: some View {
        Group {
            if let url = song.artworkURL {
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
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.secondary.opacity(0.2))
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            )
    }

    private var formattedDuration: String {
        let total = Int(song.duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
