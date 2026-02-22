//
//  FollowService.swift
//  Front Nine
//

import Foundation
import os

/// Manages follow/unfollow relationships with atomic Firestore batch writes.
/// Maintains a local cache of who the current user follows for instant UI checks.
@MainActor @Observable
final class FollowService {
    private let firestoreService: any FirestoreServiceProtocol
    private let logger = Logger(subsystem: "com.frontnine", category: "Follow")

    /// UIDs the current user is following (local cache for instant lookups)
    private(set) var followingUids: Set<String> = []

    init(firestoreService: (any FirestoreServiceProtocol)? = nil) {
        self.firestoreService = firestoreService ?? FirestoreService()
    }

    // MARK: - Follow State

    /// Check if the current user follows a given user (from local cache).
    func isFollowing(_ targetUid: String) -> Bool {
        followingUids.contains(targetUid)
    }

    /// Load the current user's following list into the local cache.
    /// Call this once after sign-in.
    func loadFollowingState(uid: String) async {
        do {
            let uids = try await firestoreService.fetchFollowingUids(uid: uid)
            followingUids = Set(uids)
        } catch {
            logger.error("Failed to load following state: \(error.localizedDescription)")
        }
    }

    /// Clear local cache on sign-out.
    func reset() {
        followingUids = []
    }

    // MARK: - Follow / Unfollow

    /// Follow a user. Atomic batch write: creates both subcollection docs and increments both counts.
    func follow(targetUid: String, currentUid: String) async throws {
        try await firestoreService.followUser(currentUid: currentUid, targetUid: targetUid)
        followingUids.insert(targetUid)
    }

    /// Unfollow a user. Atomic batch write: deletes both subcollection docs and decrements both counts.
    func unfollow(targetUid: String, currentUid: String) async throws {
        try await firestoreService.unfollowUser(currentUid: currentUid, targetUid: targetUid)
        followingUids.remove(targetUid)
    }

    // MARK: - Fetch Lists

    /// Fetch profiles of users that the given user follows.
    /// Returns profiles in most-recently-followed order.
    func fetchFollowing(uid: String) async throws -> [UserProfile] {
        let uids = try await firestoreService.fetchFollowingUids(uid: uid)
        guard !uids.isEmpty else { return [] }
        return try await firestoreService.fetchUserProfiles(uids: uids)
    }

    /// Fetch profiles of users that follow the given user.
    /// Returns profiles in most-recently-followed order.
    func fetchFollowers(uid: String) async throws -> [UserProfile] {
        let uids = try await firestoreService.fetchFollowerUids(uid: uid)
        guard !uids.isEmpty else { return [] }
        return try await firestoreService.fetchUserProfiles(uids: uids)
    }

    // MARK: - User Search

    /// Search users by name or handle prefix. Excludes the current user from results.
    func searchUsers(prefix: String, currentUid: String?) async throws -> [UserProfile] {
        let results = try await firestoreService.searchUsers(query: prefix, limit: 20)
        guard let currentUid else { return results }
        return results.filter { $0.uid != currentUid }
    }
}
