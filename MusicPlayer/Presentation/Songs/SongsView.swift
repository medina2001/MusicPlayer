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
        .navigationDestination(for: Song.self) { song in
            PlayerView(song: song)
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
    @State private var isSearching = false
    @State private var lastSearchedTerm: String = ""
    @State private var selectedSong: Song? = nil

    var body: some View {
        mainContent
            .accessibilityLabel("Search Songs")
            .task(id: searchText) {
                searchTask?.cancel()

                let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

                if term.isEmpty {
                    isSearching = false
                    lastSearchedTerm = ""
                    viewModel.resetSearchState()
                    searchTask = Task { await viewModel.loadRecentSongs() }
                    return
                }

                isSearching = true

                if term == lastSearchedTerm { return }

                do {
                    try await Task.sleep(nanoseconds: 500_000_000)
                } catch {
                    isSearching = false
                    return
                }

                if Task.isCancelled { return }

                let currentTerm = term
                lastSearchedTerm = currentTerm

                searchTask = Task { [currentTerm] in
                    await viewModel.search(term: currentTerm)
                }

                await searchTask?.value
                isSearching = false
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $selectedSong) { song in
                PlayerView(song: song)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search"
            )
            .onAppear {
                isSearching = false
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    lastSearchedTerm = ""
                    viewModel.resetSearchState()
                    Task { await viewModel.loadRecentSongs() }
                }
            }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.viewState {
        case .idle:
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                recentSongsList
            }
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let songs):
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if songs.isEmpty {
                emptyStateView
            } else {
                songsList(songs)
            }
        case .error(let error):
            if isSearching {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView(error)
            }
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
                List(viewModel.recentSongs, id: \.id) { song in
                    Button {
                        selectedSong = song
                    } label: {
                        SongRow(song: song)
                            .accessibilityLabel("\(song.title) by \(song.artist)")
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .searchToolbarBehavior(.minimize)
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
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                Button {
                    selectedSong = song
                } label: {
                    SongRow(song: song)
                        .accessibilityLabel("\(song.title) by \(song.artist)")
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
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
        .listStyle(.plain)
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: searchText.isEmpty ? "clock.arrow.circlepath" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("Couldn't Load Songs")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                Task {
                    if searchText.isEmpty {
                        await viewModel.loadRecentSongs()
                    } else {
                        await viewModel.search(term: searchText)
                    }
                }
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

// MARK: - Song Row

struct SongRow: View {
    let song: Song

    var body: some View {
        HStack(spacing: 16) {
            artworkImage
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundStyle(.secondary)
                .frame(width: 12, height: 12)
                .onTapGesture {
                    // TODO: Display Action Sheet (Album)
                    print("Should display Action Sheet")
                }
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
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 8)
            .redacted(reason: .placeholder)
            .overlay(
                Image(systemName: "music.note")
                    .foregroundStyle(.secondary)
            )
    }
}

