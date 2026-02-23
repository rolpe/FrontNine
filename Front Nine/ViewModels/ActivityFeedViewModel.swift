//
//  ActivityFeedViewModel.swift
//  Front Nine
//

import Foundation

@MainActor @Observable
final class ActivityFeedViewModel {
    private let feedService: ActivityFeedService
    private let followService: FollowService

    private static let staleThreshold: TimeInterval = 60 // seconds

    var items: [ActivityItem] = []
    var isLoading = false
    var hasLoaded = false
    var errorMessage: String?
    private var lastFetchedAt: Date?
    private var lastFetchedFollowingCount: Int = 0

    init(feedService: ActivityFeedService? = nil, followService: FollowService) {
        self.feedService = feedService ?? ActivityFeedService()
        self.followService = followService
    }

    // MARK: - Time-Grouped Items

    var todayItems: [ActivityItem] {
        items.filter { Calendar.current.isDateInToday($0.timestamp) }
    }

    var thisWeekItems: [ActivityItem] {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date())) else {
            return []
        }
        return items.filter { item in
            !calendar.isDateInToday(item.timestamp) && item.timestamp >= weekAgo
        }
    }

    var earlierItems: [ActivityItem] {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: Date())) else {
            return items.filter { !Calendar.current.isDateInToday($0.timestamp) }
        }
        return items.filter { $0.timestamp < weekAgo }
    }

    // MARK: - Loading

    func loadFeed() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            items = try await feedService.fetchFeed(followingUids: followService.followingUids)
            lastFetchedAt = Date()
            lastFetchedFollowingCount = followService.followingUids.count
        } catch {
            errorMessage = "Unable to load activity. Please try again."
        }

        isLoading = false
        hasLoaded = true
    }

    func refresh() async {
        errorMessage = nil
        do {
            items = try await feedService.fetchFeed(followingUids: followService.followingUids)
            lastFetchedAt = Date()
            lastFetchedFollowingCount = followService.followingUids.count
        } catch {
            errorMessage = "Unable to load activity. Please try again."
        }
    }

    /// Re-fetch if following list changed or data is stale (>60s). Called on tab re-appearance.
    func refreshIfStale() async {
        guard hasLoaded, !isLoading else { return }

        // Always refresh if following list changed (new follow/unfollow)
        let followingChanged = followService.followingUids.count != lastFetchedFollowingCount
        let timeStale = lastFetchedAt.map { Date().timeIntervalSince($0) > Self.staleThreshold } ?? false

        if followingChanged || timeStale {
            await refresh()
        }
    }

    // MARK: - Relative Time

    static func relativeTime(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        guard interval > 0 else { return "now" }

        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        let weeks = Int(interval / 604800)

        if minutes < 1 { return "now" }
        if minutes < 60 { return "\(minutes)m ago" }
        if hours < 24 { return "\(hours)h ago" }
        if days < 7 { return "\(days)d ago" }
        if weeks < 4 { return "\(weeks)w ago" }

        // Beyond 4 weeks, show abbreviated date
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}
