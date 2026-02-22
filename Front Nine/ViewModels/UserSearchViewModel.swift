//
//  UserSearchViewModel.swift
//  Front Nine

import Foundation

@MainActor @Observable
final class UserSearchViewModel {
    var query = ""
    var results: [UserProfile] = []
    var isSearching = false
    var hasSearched = false

    private let followService: FollowService
    private let currentUid: String?
    private var debounceTask: Task<Void, Never>?

    init(followService: FollowService, currentUid: String?) {
        self.followService = followService
        self.currentUid = currentUid
    }

    func queryDidChange() {
        debounceTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            hasSearched = false
            isSearching = false
            return
        }

        isSearching = true
        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await search(prefix: trimmed)
        }
    }

    private func search(prefix: String) async {
        do {
            let profiles = try await followService.searchUsers(prefix: prefix, currentUid: currentUid)
            guard !Task.isCancelled else { return }
            results = profiles
        } catch {
            guard !Task.isCancelled else { return }
            results = []
        }
        isSearching = false
        hasSearched = true
    }

    func isFollowing(_ uid: String) -> Bool {
        followService.isFollowing(uid)
    }
}
