//
//  ActivityFeedService.swift
//  Front Nine
//

import Foundation
import os

/// Fetches and merges activity from multiple followed users (fan-out on read).
/// Each user's activity subcollection is queried in parallel, results merged and sorted.
@MainActor
final class ActivityFeedService {
    private let firestoreService: any FirestoreServiceProtocol
    private let logger = Logger(subsystem: "com.frontnine", category: "ActivityFeed")

    /// Max items to fetch per user before merging
    private let perUserCap = 50

    init(firestoreService: (any FirestoreServiceProtocol)? = nil) {
        self.firestoreService = firestoreService ?? FirestoreService()
    }

    /// Fetch activity from all followed users, merge by timestamp, cap at limit.
    /// Individual user fetch failures are logged and skipped (don't break the whole feed).
    func fetchFeed(followingUids: Set<String>, limit: Int = 100) async throws -> [ActivityItem] {
        guard !followingUids.isEmpty else { return [] }

        let uids = Array(followingUids)
        let service = firestoreService

        // Fan-out: query each followed user's activity in parallel
        let allItems = await withTaskGroup(of: [ActivityItem].self) { group in
            for uid in uids {
                group.addTask { @MainActor in
                    do {
                        return try await service.fetchActivity(uid: uid, limit: self.perUserCap)
                    } catch {
                        self.logger.error("Failed to fetch activity for \(uid): \(error.localizedDescription)")
                        return []
                    }
                }
            }

            var merged: [ActivityItem] = []
            for await items in group {
                merged.append(contentsOf: items)
            }
            return merged
        }

        // Sort by timestamp (newest first) and cap
        let sorted = allItems.sorted { $0.timestamp > $1.timestamp }
        return Array(sorted.prefix(limit))
    }
}
