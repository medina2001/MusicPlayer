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

    var body: some View {
        Group {
            if let viewModel {
                SongsContentView(viewModel: viewModel)
                // FIXME: Solve app navigation
                    .navigationDestination(item: $viewModel.selectedSong) { song in
                        PlayerView(song: song)
                    }
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = container.makeSongsViewModel()
            } else {
                // TODO: Handle viewDidAppear()
                viewModel.viewDidAppear()
            }
        }
    }
}

// MARK: - Content View

private struct SongsContentView: View {
    @Bindable var viewModel: SongsViewModel

    var body: some View {
        mainContent
            .accessibilityLabel("Search Songs")
            .onChange(of: viewModel.searchText) {
                viewModel.handleSearchTextChange(viewModel.searchText)
            }
//            .refreshable {
                // TODO: Check refresh logic
//                await viewModel.refresh()
//            }
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
                    viewModel.didSelectSong(song)
                } label: {
                    SongRow(song: song) {
                        viewModel.presentAlbumSheet(for: song)
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
