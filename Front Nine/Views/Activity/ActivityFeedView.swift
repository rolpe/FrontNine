//
//  ActivityFeedView.swift
//  Front Nine

import SwiftUI

/// Navigation wrapper for course detail from activity feed.
/// Includes ownerName since SocialCourseDetailView needs it for "Ranked by" attribution.
struct ActivityCourseDestination: Hashable {
    let ranking: FirestoreRanking
    let ownerName: String
}

struct ActivityFeedView: View {
    @Environment(AuthService.self) private var authService
    @Environment(FollowService.self) private var followService
    @Binding var navigationPath: NavigationPath

    @State private var viewModel: ActivityFeedViewModel?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FNColors.cream)
                .navigationTitle("Activity")
                .navigationBarTitleDisplayMode(.large)
                .toolbar(authService.authState == .signedIn ? .visible : .hidden, for: .navigationBar)
                .navigationDestination(for: ActivityCourseDestination.self) { dest in
                    SocialCourseDetailView(ranking: dest.ranking, ownerName: dest.ownerName)
                }
                .navigationDestination(for: UserProfile.self) { profile in
                    OtherUserProfileView(profile: profile)
                }
                .navigationDestination(for: FindMembersDestination.self) { _ in
                    UserSearchView()
                }
                .navigationDestination(for: ProfileDestination.self) { destination in
                    switch destination {
                    case .findMembers:
                        UserSearchView()
                    case .following(let uid):
                        FollowListView(mode: .following, uid: uid)
                    case .followers(let uid):
                        FollowListView(mode: .followers, uid: uid)
                    }
                }
        }
    }

    // MARK: - Content Routing

    @ViewBuilder
    private var content: some View {
        if authService.authState != .signedIn {
            notSignedInView
        } else if followService.followingUids.isEmpty {
            notFollowingView
        } else if let viewModel {
            feedView(viewModel)
        } else {
            ProgressView()
                .tint(FNColors.sage)
                .task {
                    let vm = ActivityFeedViewModel(followService: followService)
                    viewModel = vm
                    await vm.loadFeed()
                }
        }
    }

    // MARK: - Feed

    @ViewBuilder
    private func feedView(_ vm: ActivityFeedViewModel) -> some View {
        if vm.isLoading && !vm.hasLoaded {
            ProgressView()
                .tint(FNColors.sage)
        } else if let error = vm.errorMessage, vm.items.isEmpty {
            errorView(error)
        } else if vm.items.isEmpty && vm.hasLoaded {
            noActivityView
        } else {
            feedContent(vm)
                .onAppear { Task { await vm.refreshIfStale() } }
        }
    }

    private func feedContent(_ vm: ActivityFeedViewModel) -> some View {
        List {
            if !vm.todayItems.isEmpty {
                Section {
                    sectionHeader("TODAY")
                    feedSection(vm.todayItems)
                }
            }
            if !vm.thisWeekItems.isEmpty {
                Section {
                    sectionHeader("THIS WEEK")
                    feedSection(vm.thisWeekItems)
                }
            }
            if !vm.earlierItems.isEmpty {
                Section {
                    sectionHeader("EARLIER")
                    feedSection(vm.earlierItems)
                }
            }
        }
        .listStyle(.plain)
        .listRowSpacing(12)
        .scrollContentBackground(.hidden)
        .refreshable { await vm.refresh() }
    }

    private func feedSection(_ items: [ActivityItem]) -> some View {
        ForEach(items) { item in
            cardView(item)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FNFonts.label())
            .foregroundStyle(FNColors.warmGray)
            .kerning(0.3)
            .padding(.top, 8)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    private func cardView(_ item: ActivityItem) -> some View {
        ActivityCardView(
            item: item,
            onUserTap: {
                // Construct minimal profile for navigation (OtherUserProfileView fetches full data)
                let profile = UserProfile(
                    uid: item.actorUid,
                    displayName: item.actorDisplayName,
                    handle: item.actorHandle,
                    isPublic: true,
                    followerCount: 0,
                    followingCount: 0,
                    rankingCount: 0,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                navigationPath.append(profile)
            },
            onCourseTap: {
                let dest = ActivityCourseDestination(
                    ranking: item.toFirestoreRanking(),
                    ownerName: item.actorDisplayName
                )
                navigationPath.append(dest)
            }
        )
    }

    // MARK: - Empty States

    private var notSignedInView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "bell")
                    .font(.system(size: 48))
                    .foregroundStyle(FNColors.tan)

                Text("Activity")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(FNColors.text)

                Text("Sign in to see activity\nfrom members you follow.")
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            AppleSignInButton()
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notFollowingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 40))
                .foregroundStyle(FNColors.tan)

            Text("No activity yet")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)

            Text("Follow members to see their\nranking activity here.")
                .font(FNFonts.body())
                .foregroundStyle(FNColors.textLight)
                .multilineTextAlignment(.center)

            Button {
                // Navigate to user search
                navigationPath.append(FindMembersDestination())
            } label: {
                Text("Find Members")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 180, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(FNColors.sage)
                    )
            }
        }
    }

    private var noActivityView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundStyle(FNColors.tan)

            Text("No recent activity")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)

            Text("Members you follow haven't\nranked any courses recently.")
                .font(FNFonts.body())
                .foregroundStyle(FNColors.textLight)
                .multilineTextAlignment(.center)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(FNFonts.body())
                .foregroundStyle(FNColors.text)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel?.loadFeed() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(FNColors.coral)
            }
        }
        .padding(20)
        .background(FNColors.coral.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.coral.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Find Members Navigation

/// Lightweight destination for "Find Members" navigation from empty state.
struct FindMembersDestination: Hashable {}
