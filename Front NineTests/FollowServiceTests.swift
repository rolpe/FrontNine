//
//  FollowServiceTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

@MainActor
struct FollowServiceTests {

    // MARK: - Helpers

    private func makeSUT() -> (service: FollowService, mock: MockFirestoreService) {
        let mock = MockFirestoreService()
        let service = FollowService(firestoreService: mock)
        return (service, mock)
    }

    private func makeProfile(uid: String, handle: String = "user") -> UserProfile {
        UserProfile(uid: uid, displayName: "User", handle: handle)
    }

    // MARK: - isFollowing (local cache)

    @Test func isFollowingReturnsFalseByDefault() {
        let (service, _) = makeSUT()
        #expect(!service.isFollowing("user123"))
    }

    @Test func isFollowingReturnsTrueAfterFollow() async throws {
        let (service, _) = makeSUT()
        try await service.follow(targetUid: "user123", currentUid: "me")
        #expect(service.isFollowing("user123"))
    }

    @Test func isFollowingReturnsFalseAfterUnfollow() async throws {
        let (service, _) = makeSUT()
        try await service.follow(targetUid: "user123", currentUid: "me")
        try await service.unfollow(targetUid: "user123", currentUid: "me")
        #expect(!service.isFollowing("user123"))
    }

    // MARK: - loadFollowingState

    @Test func loadFollowingStatePopulatesCache() async {
        let (service, mock) = makeSUT()
        mock.followingUidsToReturn = ["a", "b", "c"]
        await service.loadFollowingState(uid: "me")
        #expect(service.isFollowing("a"))
        #expect(service.isFollowing("b"))
        #expect(service.isFollowing("c"))
        #expect(!service.isFollowing("d"))
    }

    @Test func loadFollowingStateHandlesError() async {
        let (service, mock) = makeSUT()
        mock.shouldThrow = true
        await service.loadFollowingState(uid: "me")
        // Should not crash, cache stays empty
        #expect(service.followingUids.isEmpty)
    }

    // MARK: - reset

    @Test func resetClearsCache() async throws {
        let (service, _) = makeSUT()
        try await service.follow(targetUid: "user123", currentUid: "me")
        #expect(service.isFollowing("user123"))

        service.reset()
        #expect(!service.isFollowing("user123"))
        #expect(service.followingUids.isEmpty)
    }

    // MARK: - follow

    @Test func followCallsFirestoreAndUpdatesCache() async throws {
        let (service, mock) = makeSUT()
        try await service.follow(targetUid: "target1", currentUid: "me")

        #expect(mock.followedPairs.count == 1)
        #expect(mock.followedPairs[0].currentUid == "me")
        #expect(mock.followedPairs[0].targetUid == "target1")
        #expect(service.isFollowing("target1"))
    }

    @Test func followThrowsOnError() async {
        let (service, mock) = makeSUT()
        mock.shouldThrow = true

        do {
            try await service.follow(targetUid: "target1", currentUid: "me")
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }

        // Cache should NOT be updated on error
        #expect(!service.isFollowing("target1"))
    }

    // MARK: - unfollow

    @Test func unfollowCallsFirestoreAndUpdatesCache() async throws {
        let (service, mock) = makeSUT()
        try await service.follow(targetUid: "target1", currentUid: "me")
        try await service.unfollow(targetUid: "target1", currentUid: "me")

        #expect(mock.unfollowedPairs.count == 1)
        #expect(mock.unfollowedPairs[0].currentUid == "me")
        #expect(mock.unfollowedPairs[0].targetUid == "target1")
        #expect(!service.isFollowing("target1"))
    }

    @Test func unfollowThrowsOnError() async throws {
        let (service, mock) = makeSUT()
        try await service.follow(targetUid: "target1", currentUid: "me")
        mock.shouldThrow = true

        do {
            try await service.unfollow(targetUid: "target1", currentUid: "me")
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }

        // Cache should NOT be updated on error — still following
        #expect(service.isFollowing("target1"))
    }

    // MARK: - fetchFollowing

    @Test func fetchFollowingReturnsProfiles() async throws {
        let (service, mock) = makeSUT()
        let profileA = makeProfile(uid: "a", handle: "alice")
        let profileB = makeProfile(uid: "b", handle: "bob")
        mock.followingUidsToReturn = ["a", "b"]
        mock.profilesToReturn = [profileA, profileB]

        let result = try await service.fetchFollowing(uid: "me")
        #expect(result.count == 2)
        #expect(result[0].uid == "a")
        #expect(result[1].uid == "b")
    }

    @Test func fetchFollowingReturnsEmptyForNoFollowing() async throws {
        let (service, mock) = makeSUT()
        mock.followingUidsToReturn = []

        let result = try await service.fetchFollowing(uid: "me")
        #expect(result.isEmpty)
    }

    // MARK: - fetchFollowers

    @Test func fetchFollowersReturnsProfiles() async throws {
        let (service, mock) = makeSUT()
        let profileA = makeProfile(uid: "a", handle: "alice")
        mock.followerUidsToReturn = ["a"]
        mock.profilesToReturn = [profileA]

        let result = try await service.fetchFollowers(uid: "me")
        #expect(result.count == 1)
        #expect(result[0].uid == "a")
    }

    // MARK: - searchUsers

    @Test func searchUsersExcludesCurrentUser() async throws {
        let (service, mock) = makeSUT()
        let me = makeProfile(uid: "me", handle: "myhandle")
        let other = makeProfile(uid: "other", handle: "otherhandle")
        mock.searchResultsToReturn = [me, other]

        let result = try await service.searchUsers(prefix: "handle", currentUid: "me")
        #expect(result.count == 1)
        #expect(result[0].uid == "other")
    }

    @Test func searchUsersReturnsAllWhenNoCurrentUid() async throws {
        let (service, mock) = makeSUT()
        let profileA = makeProfile(uid: "a", handle: "alice")
        let profileB = makeProfile(uid: "b", handle: "bob")
        mock.searchResultsToReturn = [profileA, profileB]

        let result = try await service.searchUsers(prefix: "a", currentUid: nil)
        #expect(result.count == 2)
    }

    @Test func searchUsersThrowsOnError() async {
        let (service, mock) = makeSUT()
        mock.shouldThrow = true

        do {
            _ = try await service.searchUsers(prefix: "test", currentUid: nil)
            Issue.record("Expected error to be thrown")
        } catch {
            // Expected
        }
    }
}
