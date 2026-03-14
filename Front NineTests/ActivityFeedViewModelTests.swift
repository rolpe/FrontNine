//
//  ActivityFeedViewModelTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

@MainActor
struct ActivityFeedViewModelTests {

    // MARK: - Helpers

    private func makeMock() -> MockFirestoreService {
        MockFirestoreService()
    }

    private func makeFollowService(mock: MockFirestoreService, followingUids: [String] = ["user1"]) async -> FollowService {
        let service = FollowService(firestoreService: mock)
        mock.followingUidsToReturn = followingUids
        await service.loadFollowingState(uid: "me")
        return service
    }

    private func makeSUT(
        mock: MockFirestoreService? = nil,
        activityItems: [ActivityItem] = [],
        followingUids: [String] = ["user1"]
    ) async -> (vm: ActivityFeedViewModel, mock: MockFirestoreService, followService: FollowService) {
        let mock = mock ?? makeMock()
        mock.activityToReturn = activityItems
        let followService = await makeFollowService(mock: mock, followingUids: followingUids)
        let feedService = ActivityFeedService(firestoreService: mock)
        let vm = ActivityFeedViewModel(feedService: feedService, followService: followService)
        return (vm, mock, followService)
    }

    private func makeItem(
        id: String = "item1",
        type: ActivityType = .ranked,
        actorDisplayName: String = "Tiger Woods",
        courseName: String = "Augusta National",
        newRankPosition: Int = 1,
        oldRankPosition: Int? = nil,
        timestamp: Date = Date()
    ) -> ActivityItem {
        ActivityItem(
            id: id,
            type: type,
            actorUid: "user1",
            actorDisplayName: actorDisplayName,
            actorHandle: "tiger",
            courseName: courseName,
            courseCity: "Augusta",
            courseState: "GA",
            courseCountry: "United States",
            courseRating: "Loved",
            newRankPosition: newRankPosition,
            oldRankPosition: oldRankPosition,
            courseLatitude: 33.5033,
            courseLongitude: -82.0231,
            courseType: "Public",
            courseHoleCount: 18,
            tierRank: nil,
            tierCount: nil,
            timestamp: timestamp
        )
    }

    // MARK: - Initial State

    @Test func initialStateIsEmpty() async {
        let (vm, _, _) = await makeSUT()
        #expect(vm.items.isEmpty)
        #expect(!vm.isLoading)
        #expect(!vm.hasLoaded)
        #expect(vm.errorMessage == nil)
    }

    // MARK: - loadFeed

    @Test func loadFeedPopulatesItems() async {
        let items = [makeItem(id: "1"), makeItem(id: "2")]
        let (vm, _, _) = await makeSUT(activityItems: items)

        await vm.loadFeed()

        #expect(vm.items.count == 2)
        #expect(vm.hasLoaded)
        #expect(!vm.isLoading)
    }

    @Test func loadFeedReturnsEmptyWhenFetchFails() async {
        // ActivityFeedService is error-resilient: individual user fetch failures
        // return empty (logged), don't break the feed. So when fetchActivity throws,
        // the VM gets empty items with no error message.
        let (vm, mock, _) = await makeSUT(activityItems: [makeItem()])

        // Set shouldThrow AFTER loadFollowingState (which also uses mock)
        mock.shouldThrow = true
        await vm.loadFeed()

        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage == nil) // service catches errors internally
        #expect(vm.hasLoaded)
    }

    @Test func loadFeedRecoverAfterFailure() async {
        let (vm, mock, _) = await makeSUT(activityItems: [makeItem()])

        // First load fails silently (empty results)
        mock.shouldThrow = true
        await vm.loadFeed()
        #expect(vm.items.isEmpty)

        // Second load succeeds
        mock.shouldThrow = false
        mock.activityToReturn = [makeItem()]
        await vm.loadFeed()

        #expect(vm.items.count == 1)
    }

    @Test func loadFeedReturnsEmptyForNoFollowing() async {
        let (vm, _, _) = await makeSUT(followingUids: [])

        await vm.loadFeed()

        #expect(vm.items.isEmpty)
        #expect(vm.hasLoaded)
    }

    // MARK: - Time Grouping

    @Test func todayItemsFiltersCorrectly() async {
        let todayItem = makeItem(id: "today", timestamp: Date())
        let yesterdayItem = makeItem(id: "yesterday", timestamp: Date().addingTimeInterval(-86400))
        let (vm, _, _) = await makeSUT(activityItems: [todayItem, yesterdayItem])

        await vm.loadFeed()

        #expect(vm.todayItems.count == 1)
        #expect(vm.todayItems.first?.id == "today")
    }

    @Test func thisWeekItemsExcludesToday() async {
        let todayItem = makeItem(id: "today", timestamp: Date())
        let twoDaysAgo = makeItem(id: "2d", timestamp: Date().addingTimeInterval(-2 * 86400))
        let (vm, _, _) = await makeSUT(activityItems: [todayItem, twoDaysAgo])

        await vm.loadFeed()

        #expect(vm.thisWeekItems.count == 1)
        #expect(vm.thisWeekItems.first?.id == "2d")
    }

    @Test func earlierItemsExcludesThisWeek() async {
        let todayItem = makeItem(id: "today", timestamp: Date())
        let twoWeeksAgo = makeItem(id: "2w", timestamp: Date().addingTimeInterval(-14 * 86400))
        let (vm, _, _) = await makeSUT(activityItems: [todayItem, twoWeeksAgo])

        await vm.loadFeed()

        #expect(vm.earlierItems.count == 1)
        #expect(vm.earlierItems.first?.id == "2w")
    }

    @Test func allThreeGroupsPopulated() async {
        let today = makeItem(id: "today", timestamp: Date())
        let threeDaysAgo = makeItem(id: "3d", timestamp: Date().addingTimeInterval(-3 * 86400))
        let twoWeeksAgo = makeItem(id: "2w", timestamp: Date().addingTimeInterval(-14 * 86400))
        let (vm, _, _) = await makeSUT(activityItems: [today, threeDaysAgo, twoWeeksAgo])

        await vm.loadFeed()

        #expect(vm.todayItems.count == 1)
        #expect(vm.thisWeekItems.count == 1)
        #expect(vm.earlierItems.count == 1)
    }

    // MARK: - refresh

    @Test func refreshReplacesItems() async {
        let item1 = makeItem(id: "old")
        let (vm, mock, _) = await makeSUT(activityItems: [item1])

        await vm.loadFeed()
        #expect(vm.items.count == 1)

        let item2 = makeItem(id: "new")
        mock.activityToReturn = [item2]
        await vm.refresh()

        #expect(vm.items.count == 1)
        #expect(vm.items.first?.id == "new")
    }

    @Test func refreshReturnsEmptyOnFailure() async {
        let (vm, mock, _) = await makeSUT(activityItems: [makeItem()])

        await vm.loadFeed()
        #expect(vm.items.count == 1)

        // Service catches errors internally — refresh gets empty, not an error
        mock.shouldThrow = true
        await vm.refresh()

        #expect(vm.items.isEmpty)
        #expect(vm.errorMessage == nil)
    }

    // MARK: - refreshIfStale

    @Test func refreshIfStaleDoesNothingBeforeFirstLoad() async {
        let (vm, _, _) = await makeSUT(activityItems: [makeItem()])

        await vm.refreshIfStale()

        // Should not have loaded anything since hasLoaded is false
        #expect(vm.items.isEmpty)
    }

    @Test func refreshIfStaleDoesNothingWhenFresh() async {
        let item = makeItem(id: "original")
        let (vm, mock, _) = await makeSUT(activityItems: [item])

        await vm.loadFeed()

        // Change mock data — if refreshIfStale triggers, items would change
        mock.activityToReturn = [makeItem(id: "refreshed")]
        await vm.refreshIfStale()

        // Should still have original since data isn't stale
        #expect(vm.items.first?.id == "original")
    }

    // MARK: - relativeTime

    @Test func relativeTimeNow() {
        let result = ActivityFeedViewModel.relativeTime(from: Date())
        #expect(result == "now")
    }

    @Test func relativeTimeSeconds() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-30))
        #expect(result == "now")
    }

    @Test func relativeTimeMinutes() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-300))
        #expect(result == "5m ago")
    }

    @Test func relativeTimeHours() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-7200))
        #expect(result == "2h ago")
    }

    @Test func relativeTimeDays() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-3 * 86400))
        #expect(result == "3d ago")
    }

    @Test func relativeTimeWeeks() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-14 * 86400))
        #expect(result == "2w ago")
    }

    @Test func relativeTimeBeyondFourWeeks() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(-35 * 86400))
        // Should return abbreviated date format (e.g., "Jan 19")
        #expect(!result.contains("ago"))
        #expect(!result.contains("w"))
    }

    @Test func relativeTimeFutureDate() {
        let result = ActivityFeedViewModel.relativeTime(from: Date().addingTimeInterval(3600))
        #expect(result == "now")
    }
}
