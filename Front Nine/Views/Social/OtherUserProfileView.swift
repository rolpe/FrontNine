//
//  OtherUserProfileView.swift
//  Front Nine

import SwiftUI

struct OtherUserProfileView: View {
    @Environment(FollowService.self) private var followService
    @Environment(AuthService.self) private var authService

    let profile: UserProfile
    @State private var viewModel: OtherUserProfileViewModel?

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FNColors.cream)
            .navigationTitle("@\(profile.handle)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel == nil {
                    viewModel = OtherUserProfileViewModel(
                        profile: profile,
                        followService: followService,
                        currentUid: authService.userProfile?.uid
                    )
                }
            }
            .task {
                // Small delay to let viewModel initialize via onAppear
                try? await Task.sleep(for: .milliseconds(50))
                await viewModel?.refreshProfile()
                await viewModel?.loadRankings()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            profileContent(viewModel)
        } else {
            ProgressView()
                .tint(FNColors.sage)
        }
    }

    private func profileContent(_ vm: OtherUserProfileViewModel) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                VStack(spacing: 8) {
                    ProfileAvatarView(
                        name: vm.profile.displayName,
                        photoURL: vm.profile.photoURL,
                        uid: vm.profile.uid,
                        size: 80
                    )

                    Text(vm.profile.displayName)
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(FNColors.text)

                    Text("@\(vm.profile.handle)")
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.top, 16)

                // Stats row
                HStack(spacing: 32) {
                    statItem(count: vm.profile.rankingCount, label: "Ranked")

                    NavigationLink(value: ProfileDestination.followers(uid: vm.profile.uid)) {
                        statItem(count: vm.profile.followerCount, label: "Followers")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: ProfileDestination.following(uid: vm.profile.uid)) {
                        statItem(count: vm.profile.followingCount, label: "Following")
                    }
                    .buttonStyle(.plain)
                }

                // Follow button (hidden for own profile)
                if !vm.isOwnProfile {
                    followButton(vm)
                }

                // Rankings or privacy lock
                if vm.canViewRankings {
                    rankingsSection(vm)
                } else {
                    privateLock(vm)
                }
            }
            .padding(.bottom, 40)
        }
        .navigationDestination(for: FirestoreRanking.self) { ranking in
            SocialCourseDetailView(ranking: ranking, ownerName: vm.profile.displayName)
        }
    }

    // MARK: - Components

    private func statItem(count: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(FNColors.textLight)
        }
    }

    private func followButton(_ vm: OtherUserProfileViewModel) -> some View {
        Button {
            Task {
                let wasFollowing = vm.isFollowing
                await vm.toggleFollow()
                // Update local following count so ProfileView reflects the change
                let currentCount = authService.userProfile?.followingCount ?? 0
                if wasFollowing && !vm.isFollowing {
                    authService.userProfile?.followingCount = max(0, currentCount - 1)
                } else if !wasFollowing && vm.isFollowing {
                    authService.userProfile?.followingCount = currentCount + 1
                }
            }
        } label: {
            HStack(spacing: 6) {
                if vm.isFollowActionInProgress {
                    ProgressView()
                        .controlSize(.small)
                        .tint(vm.isFollowing ? FNColors.sage : .white)
                } else {
                    Image(systemName: vm.isFollowing ? "person.badge.minus" : "person.badge.plus")
                        .font(.system(size: 14, weight: .medium))
                }
                Text(vm.isFollowing ? "Unfollow" : "Follow")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(vm.isFollowing ? FNColors.sage : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(vm.isFollowing ? Color.clear : FNColors.sage)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FNColors.sage, lineWidth: vm.isFollowing ? 1.5 : 0)
            )
        }
        .disabled(vm.isFollowActionInProgress)
        .padding(.horizontal, 20)
    }

    private func privateLock(_ vm: OtherUserProfileViewModel) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundStyle(FNColors.tan)

            Text("Private Rankings")
                .font(FNFonts.bodyMedium())
                .foregroundStyle(FNColors.text)

            Text("Follow \(vm.profile.displayName) to see their rankings")
                .font(FNFonts.subtext())
                .foregroundStyle(FNColors.textLight)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
        .padding(.horizontal, 20)
    }

    private func rankingsSection(_ vm: OtherUserProfileViewModel) -> some View {
        VStack(spacing: 0) {
            if vm.isLoadingRankings {
                ProgressView()
                    .tint(FNColors.sage)
                    .padding(.top, 32)
            } else if vm.rankings.isEmpty {
                VStack(spacing: 8) {
                    Text("No rankings yet")
                        .font(FNFonts.bodyMedium())
                        .foregroundStyle(FNColors.text)
                    Text("\(vm.profile.displayName) hasn't ranked any courses")
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.top, 32)
            } else {
                VStack(spacing: 0) {
                    tierSection(rating: .loved, rankings: vm.lovedRankings)
                    tierSection(rating: .liked, rankings: vm.likedRankings)
                    tierSection(rating: .disliked, rankings: vm.didntLoveRankings)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func tierSection(rating: Rating, rankings: [FirestoreRanking]) -> some View {
        Group {
            if !rankings.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    TierHeaderView(rating: rating, count: rankings.count)
                        .padding(.top, 16)
                        .padding(.bottom, 4)

                    ForEach(rankings, id: \.id) { ranking in
                        NavigationLink(value: ranking) {
                            OtherUserCourseRow(ranking: ranking)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
