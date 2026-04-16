import Foundation
@testable import MusicPlayer

final class SongsRepositoryMock: SongsRepository {
    var songsToReturn: [Song] = []
    var errorToThrow: Error?
    private(set) var receivedTerms: [String] = []
    private(set) var receivedOffsets: [Int] = []

    func fetchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        receivedTerms.append(term)
        receivedOffsets.append(offset)
        if let errorToThrow {
            throw errorToThrow
        }
        return songsToReturn
    }
}

final class AlbumsRepositoryMock: AlbumsRepository {
    var albumToReturn: Album?
    var errorToThrow: Error?
    private(set) var requestedCollectionIDs: [Int] = []

    func fetchAlbum(collectionId: Int) async throws -> Album {
        requestedCollectionIDs.append(collectionId)
        if let errorToThrow {
            throw errorToThrow
        }
        return albumToReturn ?? Album(id: collectionId, title: "", artist: "", artworkURL: nil, songs: [])
    }
}

final class RecentSongsRepositoryMock: RecentSongsRepository {
    var recentSongsToReturn: [Song] = []
    var fetchError: Error?
    private(set) var savedSongs: [Song] = []

    func fetchRecentSongs() async throws -> [Song] {
        if let fetchError {
            throw fetchError
        }
        return recentSongsToReturn
    }

    func save(song: Song) async throws {
        savedSongs.append(song)
    }
}

final class PlayerServiceMock: PlayerService {
    var state: PlayerState = .idle
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 30

    private(set) var loadedURLs: [URL] = []
    private(set) var playCallCount = 0
    private(set) var pauseCallCount = 0
    private(set) var seekTimes: [TimeInterval] = []
    private(set) var releaseCallCount = 0

    func load(url: URL) {
        loadedURLs.append(url)
        state = .loading
    }

    func play() {
        playCallCount += 1
        state = .playing
    }

    func pause() {
        pauseCallCount += 1
        state = .paused
    }

    func seek(to time: TimeInterval) {
        seekTimes.append(time)
        currentTime = time
    }

    func release() {
        releaseCallCount += 1
        state = .idle
    }
}

final class ConnectivityServiceMock: ConnectivityMonitoring {
    var isConnected: Bool

    init(isConnected: Bool) {
        self.isConnected = isConnected
    }
}
