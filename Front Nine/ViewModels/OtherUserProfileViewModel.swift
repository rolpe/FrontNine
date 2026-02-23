//
//  OtherUserProfileViewModel.swift
//  Front Nine

import Foundation
import os

@MainActor @Observable
final class OtherUserProfileViewModel {
    private(set) var profile: UserProfile
    private let followService: FollowService
    private let firestoreService: any FirestoreServiceProtocol
    private let currentUid: String?
    private let logger = Logger(subsystem: "com.frontnine", category: "OtherUserProfile")

    var rankings: [FirestoreRanking] = []
    var isLoadingRankings = false
    var isFollowActionInProgress = false

    var isFollowing: Bool {
        guard currentUid != nil else { return false }
        return followService.isFollowing(profile.uid)
    }

    /// Whether the current user can see this user's rankings.
    var canViewRankings: Bool {
        // Own profile — always visible
        if currentUid == profile.uid { return true }
        return profile.isPublic || isFollowing
    }

    var isOwnProfile: Bool {
        currentUid == profile.uid
    }

    // Tier-grouped rankings
    var lovedRankings: [FirestoreRanking] {
        rankings.filter { $0.rating == Rating.loved.rawValue }
    }

    var likedRankings: [FirestoreRanking] {
        rankings.filter { $0.rating == Rating.liked.rawValue }
    }

    var didntLoveRankings: [FirestoreRanking] {
        rankings.filter { $0.rating == Rating.disliked.rawValue }
    }

    init(
        profile: UserProfile,
        followService: FollowService,
        firestoreService: (any FirestoreServiceProtocol)? = nil,
        currentUid: String?
    ) {
        self.profile = profile
        self.followService = followService
        self.firestoreService = firestoreService ?? FirestoreService()
        self.currentUid = currentUid
    }

    /// Fetch the latest profile from Firestore to ensure counts are current.
    func refreshProfile() async {
        do {
            if let fresh = try await firestoreService.fetchUserProfile(uid: profile.uid) {
                profile = fresh
            }
        } catch {
            logger.error("Failed to refresh profile for \(self.profile.uid): \(error.localizedDescription)")
        }
    }

    func loadRankings() async {
        guard canViewRankings, rankings.isEmpty else { return }
        isLoadingRankings = true
        do {
            rankings = try await firestoreService.fetchRankings(uid: profile.uid)
        } catch {
            logger.error("Failed to load rankings for \(self.profile.uid): \(error.localizedDescription)")
            rankings = []
        }
        isLoadingRankings = false
    }

    func toggleFollow() async {
        guard let currentUid, !isFollowActionInProgress else { return }
        isFollowActionInProgress = true

        do {
            if isFollowing {
                try await followService.unfollow(targetUid: profile.uid, currentUid: currentUid)
                profile.followerCount = max(0, profile.followerCount - 1)
            } else {
                try await followService.follow(targetUid: profile.uid, currentUid: currentUid)
                profile.followerCount += 1
                // After following, load rankings if we now have access
                if canViewRankings && rankings.isEmpty {
                    await loadRankings()
                }
            }
        } catch {
            logger.error("Follow action failed: \(error.localizedDescription)")
        }

        isFollowActionInProgress = false
    }
}
