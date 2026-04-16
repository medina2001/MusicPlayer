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
    private(set) var viewState: ViewState<[Song]> = .loading
    private(set) var recentSongs: [Song] = []
    private(set) var loadedSongs: [Song] = []
    private(set) var paginationExhausted: Bool = false
    private(set) var isLoadingPage: Bool = false
    
    private(set) var lastSearchedTerm: String = ""
    private var searchTask: Task<Void, Never>? = nil
    private(set) var isSearching = false
    var searchText = ""
    
    var selectedSong: Song? = nil

    private var currentTerm: String = ""
    private var currentOffset: Int = 0
    private let pageSize: Int = 25

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
            viewState = .error(.unknownError)
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
        } catch {
            // Did not load new page
            return
        }
    }

    func refresh() async {
        // TODO: Check logic
        currentOffset = 0
        paginationExhausted = false
        await search(term: currentTerm)
    }

    func resetSearchState() {
        currentTerm = ""
        currentOffset = 0
        paginationExhausted = false
        // TODO: Check View State
    }

    func loadRecentSongs() async {
        do {
            recentSongs = try await recentSongsRepository.fetchRecentSongs()
        } catch {
            print("Could not load recent songs. \(#function) in \(#file)")
        }
    }
    
    func handleSearchTextChange(_ term: String) {
        searchTask?.cancel()
        
        let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedTerm != lastSearchedTerm else { return }
        
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            
            if Task.isCancelled { return }
            
            await performSearch(trimmedTerm)
        }
    }
    
    private func performSearch(_ term: String) async {
        lastSearchedTerm = term
        
        if term.isEmpty {
            resetSearchState()
            await loadRecentSongs()
            return
        }
        
        await search(term: term)
    }
    
    func tryAgain() async {
        if searchText.isEmpty {
            await loadRecentSongs()
        } else {
            await search(term: searchText)
        }
    }
    
    func didSelectSong(_ song: Song) {
        selectedSong = song
    }
    
    func presentAlbumSheet(for song: Song) {
        
    }
}

