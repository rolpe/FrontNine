//
//  FollowListView.swift
//  Front Nine

import SwiftUI

enum FollowListMode {
    case following
    case followers

    var title: String {
        switch self {
        case .following: return "Following"
        case .followers: return "Followers"
        }
    }

    var emptyMessage: String {
        switch self {
        case .following: return "Not following anyone yet"
        case .followers: return "No followers yet"
        }
    }

    var emptySubtitle: String {
        switch self {
        case .following: return "Find members to follow using Search"
        case .followers: return "Share your profile to get followers"
        }
    }
}

struct FollowListView: View {
    @Environment(FollowService.self) private var followService
    @Environment(AuthService.self) private var authService

    let mode: FollowListMode
    let uid: String

    @State private var profiles: [UserProfile] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(FNColors.sage)
                    Spacer()
                }
            } else if profiles.isEmpty {
                VStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "person.2")
                            .font(.system(size: 36))
                            .foregroundStyle(FNColors.tan)
                        Text(mode.emptyMessage)
                            .font(FNFonts.bodyMedium())
                            .foregroundStyle(FNColors.text)
                        Text(mode.emptySubtitle)
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.textLight)
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(profiles, id: \.uid) { profile in
                            NavigationLink(value: profile) {
                                FollowRow(
                                    profile: profile,
                                    isFollowing: followService.isFollowing(profile.uid),
                                    isCurrentUser: profile.uid == authService.userProfile?.uid
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadProfiles() }
    }

    private func loadProfiles() async {
        isLoading = true
        do {
            switch mode {
            case .following:
                profiles = try await followService.fetchFollowing(uid: uid)
            case .followers:
                profiles = try await followService.fetchFollowers(uid: uid)
            }
        } catch {
            profiles = []
        }
        isLoading = false
    }
}

// MARK: - Row

private struct FollowRow: View {
    let profile: UserProfile
    let isFollowing: Bool
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 14) {
            InitialsAvatarView(name: profile.displayName, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(FNFonts.bodyMedium())
                    .foregroundStyle(FNColors.text)

                Text("@\(profile.handle)")
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
            }

            Spacer()

            if isCurrentUser {
                Text("You")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(FNColors.textLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(FNColors.tan.opacity(0.3))
                    )
            } else if isFollowing {
                Text("Following")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(FNColors.sage)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(FNColors.sage.opacity(0.12))
                    )
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FNColors.tan)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
