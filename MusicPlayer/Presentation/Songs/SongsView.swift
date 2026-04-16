//
//  SongsView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct SongsView: View {
    let router: AppRouter

    @State private var viewModel: SongsViewModel

    init(container: DependencyContainer, router: AppRouter) {
        self.router = router
        _viewModel = State(initialValue: container.makeSongsViewModel())
    }

    var body: some View {
        SongsContentView(
            viewModel: viewModel,
            onSelectSong: handleSongSelection,
            onViewAlbum: handleViewAlbum
        )
        .onAppear(perform: viewModel.viewDidAppear)
    }

    private func handleSongSelection(_ song: Song) {
        router.presentPlayer(song: song, queue: viewModel.visibleSongs)
    }

    private func handleViewAlbum(_ song: Song) {
        router.presentAlbum(for: song)
    }
}

// MARK: - Content View

private struct SongsContentView: View {
    @Bindable var viewModel: SongsViewModel
    let onSelectSong: (Song) -> Void
    let onViewAlbum: (Song) -> Void

    var body: some View {
        mainContent
            .scrollIndicators(.hidden)
            .accessibilityLabel("Search Songs")
            .onChange(of: viewModel.searchText) {
                viewModel.handleSearchTextChange(viewModel.searchText)
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.automatic)
            .searchable(
                text: $viewModel.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search"
            )
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.viewState {
        case .idle:
            ProgressView()
                .controlSize(.extraLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading:
            ProgressView()
                .controlSize(.extraLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let songs):
            if songs.isEmpty {
                ContentUnavailableView(
                    "No Recent Songs",
                    systemImage: "music.note",
                    description: Text("Search for songs to get started.")
                )
            } else {
                songsList(songs)
            }
        case .error(let error):
            ErrorView(error: error) {
                Task {
                    await viewModel.tryAgain()
                }
            }
        }
    }

    private func songsList(_ songs: [Song]) -> some View {
        List {
            ForEach(Array(songs.enumerated()), id: \.offset) { index, song in
                Button {
                    onSelectSong(song)
                } label: {
                    SongRow(song: song) {
                        onViewAlbum(song)
                    }
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
                        .controlSize(.large)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
