//
//  DefaultRecentSongsRepository.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "com.musicplayer", category: "persistence")

final class DefaultRecentSongsRepository: RecentSongsRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchRecentSongs() async throws -> [Song] {
        do {
            let descriptor = FetchDescriptor<RecentSongRecord>(
                sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
            )
            let records = try context.fetch(descriptor)
            return records.map { $0.toDomain() }
        } catch {
            logger.error("persistenceFailure: failed to fetch recent songs — \(error.localizedDescription)")
            return []
        }
    }

    func save(song: Song) async throws {
        do {
            let songId = song.id
            let dedupeDescriptor = FetchDescriptor<RecentSongRecord>(
                predicate: #Predicate { $0.songId == songId }
            )
            let existing = try context.fetch(dedupeDescriptor)
            existing.forEach { context.delete($0) }

            let record = RecentSongRecord(song: song, playedAt: .now)
            context.insert(record)

            let allDescriptor = FetchDescriptor<RecentSongRecord>(
                sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
            )
            let all = try context.fetch(allDescriptor)
            if all.count > 50 {
                all.dropFirst(50).forEach { context.delete($0) }
            }

            try context.save()
        } catch {
            logger.error("persistenceFailure: failed to save song '\(song.title)' — \(error.localizedDescription)")
        }
    }
}
