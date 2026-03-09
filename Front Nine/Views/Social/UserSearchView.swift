//
//  UserSearchView.swift
//  Front Nine

import SwiftUI

struct UserSearchView: View {
    @Environment(FollowService.self) private var followService
    @Environment(AuthService.self) private var authService

    @State private var viewModel: UserSearchViewModel?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FNColors.cream)
            .navigationTitle("Find Members")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel == nil {
                    viewModel = UserSearchViewModel(
                        followService: followService,
                        currentUid: authService.userProfile?.uid
                    )
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel {
            searchContent(viewModel)
        } else {
            ProgressView()
                .tint(FNColors.sage)
        }
    }

    private func searchContent(_ vm: UserSearchViewModel) -> some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(FNColors.warmGray)
                    .font(.system(size: 16))

                TextField("Search by name or handle...", text: Binding(
                    get: { vm.query },
                    set: { newValue in
                        vm.query = newValue
                        vm.queryDidChange()
                    }
                ))
                .font(.system(size: 16))
                .focused($isSearchFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                if !vm.query.isEmpty {
                    Button {
                        vm.query = ""
                        vm.queryDidChange()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(FNColors.warmGray)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FNColors.tan, lineWidth: 1.5)
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .onAppear { isSearchFocused = true }

            // Results
            if vm.isSearching {
                Spacer()
                ProgressView()
                    .tint(FNColors.sage)
                Spacer()
            } else if vm.hasSearched && vm.results.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Text("No users found")
                        .font(FNFonts.bodyMedium())
                        .foregroundStyle(FNColors.text)
                    Text("Try a different name or handle")
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)
                }
                Spacer()
            } else if !vm.results.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.results, id: \.uid) { profile in
                            NavigationLink(value: profile) {
                                UserSearchRow(
                                    profile: profile,
                                    isFollowing: vm.isFollowing(profile.uid)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 8)
                }
                .scrollDismissesKeyboard(.immediately)
            } else {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "person.2")
                        .font(.system(size: 36))
                        .foregroundStyle(FNColors.tan)
                    Text("Search by name or handle")
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Search Result Row

private struct UserSearchRow: View {
    let profile: UserProfile
    let isFollowing: Bool

    var body: some View {
        HStack(spacing: 14) {
            ProfileAvatarView(
                name: profile.displayName,
                photoURL: profile.photoURL,
                uid: profile.uid,
                size: 44
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(FNFonts.bodyMedium())
                    .foregroundStyle(FNColors.text)

                Text("@\(profile.handle)")
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
            }

            Spacer()

            if isFollowing {
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
