//
//  SongsViewModel.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Observation
import Foundation

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
        currentTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        if currentTerm.isEmpty { return }

        currentOffset = 0
        paginationExhausted = false
        viewState = .loading

        do {
            let songs = try await songsRepository.fetchSongs(term: currentTerm, limit: pageSize, offset: 0)

            if Task.isCancelled { return }

            paginationExhausted = songs.count < pageSize
            viewState = .loaded(songs)
        } catch let error as AppError {
            if Task.isCancelled { return }
            switch error {
            case .requestCancelled:
                return
            default:
                viewState = .error(error)
            }
        } catch is CancellationError {
            return
        } catch {
            if Task.isCancelled { return }
            viewState = .error(.networkUnavailable)
        }
    }

    func loadNextPage() async {
        guard !isLoadingPage else { return }
        guard !paginationExhausted else { return }
        guard case .loaded(let songs) = viewState else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }

        let nextOffset = currentOffset + pageSize

        do {
            let newSongs = try await songsRepository.fetchSongs(term: currentTerm, limit: pageSize, offset: nextOffset)

            if Task.isCancelled { return }

            currentOffset = nextOffset
            if newSongs.count < pageSize { paginationExhausted = true }
            viewState = .loaded(songs + newSongs)
        } catch is CancellationError {
            // AppError.requestCancelled – ignore for pagination
            return
        } catch {
            // Keep existing loaded state on pagination failure
        }
    }

    func refresh() async {
        currentOffset = 0
        paginationExhausted = false
        await search(term: currentTerm)
    }

    func resetSearchState() {
        currentTerm = ""
        currentOffset = 0
        paginationExhausted = false
        viewState = .idle
    }

    func loadRecentSongs() async {
        do {
            recentSongs = try await recentSongsRepository.fetchRecentSongs()
        } catch {
            print("Could not load recent songs. \(#function) in \(#file)")
        }
    }
}

