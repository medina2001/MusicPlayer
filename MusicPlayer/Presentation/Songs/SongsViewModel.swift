//
//  SongsViewModel.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Observation

@Observable
@MainActor
final class SongsViewModel {
    private(set) var viewState: ViewState<[Song]> = .idle
    private(set) var recentSongs: [Song] = []
    private(set) var paginationExhausted: Bool = false
    private(set) var isLoadingPage: Bool = false

    private var currentTerm: String = ""
    private var currentOffset: Int = 0
    private let pageSize: Int = 20

    private let songsRepository: SongsRepository
    private let recentSongsRepository: RecentSongsRepository

    init(songsRepository: SongsRepository, recentSongsRepository: RecentSongsRepository) {
        self.songsRepository = songsRepository
        self.recentSongsRepository = recentSongsRepository
    }

    func search(term: String) async {
        currentTerm = term
        currentOffset = 0
        paginationExhausted = false
        viewState = .loading
        do {
            let songs = try await songsRepository.fetchSongs(term: term, limit: pageSize, offset: 0)
            if songs.count < pageSize { paginationExhausted = true }
            viewState = .loaded(songs)
        } catch let error as AppError {
            viewState = .error(error)
        } catch {
            viewState = .error(.networkUnavailable)
        }
    }

    func loadNextPage() async {
        guard !isLoadingPage else { return }
        guard !paginationExhausted else { return }
        guard case .loaded(let songs) = viewState else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }
        do {
            let newSongs = try await songsRepository.fetchSongs(term: currentTerm, limit: pageSize, offset: currentOffset + pageSize)
            currentOffset += pageSize
            if newSongs.count < pageSize { paginationExhausted = true }
            viewState = .loaded(songs + newSongs)
        } catch {
            // Don't overwrite the loaded state on pagination error — just stop loading
        }
    }

    func refresh() async {
        currentOffset = 0
        paginationExhausted = false
        await search(term: currentTerm)
    }

    func loadRecentSongs() async {
        do {
            recentSongs = try await recentSongsRepository.fetchRecentSongs()
        } catch {
            // Silently fail — recent songs are non-critical
        }
    }
}
