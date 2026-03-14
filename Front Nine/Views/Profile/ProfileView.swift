//
//  ProfileView.swift
//  Front Nine
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(FollowService.self) private var followService
    @Environment(ProfilePhotoService.self) private var photoService
    @Environment(\.dismiss) private var dismiss

    var showDismissButton: Bool = true

    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?
    @State private var isTogglingPrivacy = false

    // Photo picker state
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    private var memberSinceText: String {
        guard let profile = authService.userProfile else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: profile.createdAt))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                if let profile = authService.userProfile {
                    VStack(spacing: 8) {
                        // Tappable avatar with camera badge
                        Button { showPhotoOptions = true } label: {
                            ZStack(alignment: .bottomTrailing) {
                                ProfileAvatarView(
                                    name: profile.displayName,
                                    photoURL: profile.photoURL,
                                    uid: profile.uid,
                                    size: 80
                                )

                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 24))
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, FNColors.sage)
                                    .offset(x: 4, y: 4)
                            }
                        }
                        .disabled(photoService.isUploading)

                        if photoService.isUploading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(FNColors.sage)
                        }

                            Text(profile.displayName)
                                .font(.system(size: 24, weight: .semibold, design: .serif))
                                .foregroundStyle(FNColors.text)

                            Text("@\(profile.handle)")
                                .font(FNFonts.subtext())
                                .foregroundStyle(FNColors.textLight)

                            Text(memberSinceText)
                                .font(.system(size: 13))
                                .foregroundStyle(FNColors.warmGray)
                                .padding(.top, 4)
                        }
                        .padding(.top, 16)

                        // Stats row
                        HStack(spacing: 32) {
                            statItem(count: profile.rankingCount, label: "Ranked")

                            NavigationLink(value: ProfileDestination.followers(uid: profile.uid)) {
                                statItem(count: profile.followerCount, label: "Followers")
                            }
                            .buttonStyle(.plain)

                            NavigationLink(value: ProfileDestination.following(uid: profile.uid)) {
                                statItem(count: profile.followingCount, label: "Following")
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Social section
                    socialSection

                    // Privacy toggle
                    if let profile = authService.userProfile {
                        VStack(spacing: 6) {
                            Toggle(isOn: Binding(
                                get: { profile.isPublic },
                                set: { _ in togglePrivacy() }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Public Profile")
                                        .font(FNFonts.bodyMedium())
                                        .foregroundStyle(FNColors.text)
                                    Text("When off, only followers can see your rankings")
                                        .font(.system(size: 13))
                                        .foregroundStyle(FNColors.textLight)
                                }
                            }
                            .tint(FNColors.sage)
                            .disabled(isTogglingPrivacy)
                        }
                        .padding(.horizontal, 20)
                    }

                    // Error message
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(FNColors.coral)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Sign out button
                    Button {
                        signOut()
                    } label: {
                        Text("Sign Out")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(FNColors.sage)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FNColors.sage, lineWidth: 1.5)
                            )
                    }
                    .padding(.horizontal, 20)

                    // Delete account
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Text("Delete Account")
                            .font(.system(size: 14))
                            .foregroundStyle(FNColors.coral)
                    }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showDismissButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(FNColors.warmGray)
                    }
                }
            }
        }
        .task {
            await authService.refreshProfile()
        }
        .confirmationDialog("Delete Account", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your profile. Your local rankings will not be affected.")
        }
        .confirmationDialog("Profile Photo", isPresented: $showPhotoOptions) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showPhotoPicker = true }
            if authService.userProfile?.photoURL != nil {
                Button("Remove Photo", role: .destructive) { removePhoto() }
            }
            Button("Cancel", role: .cancel) { }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task { await handlePickedPhoto(item) }
            selectedPhotoItem = nil
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView { image in
                Task { await uploadPhoto(image) }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Social Section

    private var socialSection: some View {
        VStack(spacing: 0) {
            // Find Members
            NavigationLink(value: ProfileDestination.findMembers) {
                socialRow(
                    icon: "magnifyingglass",
                    title: "Find Members",
                    showChevron: true
                )
            }
            .buttonStyle(.plain)

            Divider()
                .background(FNColors.tan.opacity(0.25))
                .padding(.leading, 52)

            // Share Profile
            if let profile = authService.userProfile {
                ShareLink(item: shareMessage(for: profile)) {
                    socialRow(
                        icon: "square.and.arrow.up",
                        title: "Share Profile"
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .background(FNColors.tan.opacity(0.25))
                    .padding(.leading, 52)
            }

            // Following
            if let profile = authService.userProfile {
                NavigationLink(value: ProfileDestination.following(uid: profile.uid)) {
                    socialRow(
                        icon: "person.2",
                        title: "Following",
                        count: profile.followingCount,
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .background(FNColors.tan.opacity(0.25))
                    .padding(.leading, 52)

                // Followers
                NavigationLink(value: ProfileDestination.followers(uid: profile.uid)) {
                    socialRow(
                        icon: "person.2.fill",
                        title: "Followers",
                        count: profile.followerCount,
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
    }

    private func socialRow(icon: String, title: String, count: Int? = nil, showChevron: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(FNColors.sage)
                .frame(width: 24)

            Text(title)
                .font(FNFonts.bodyMedium())
                .foregroundStyle(FNColors.text)

            Spacer()

            if let count {
                Text("\(count)")
                    .font(.system(size: 15))
                    .foregroundStyle(FNColors.textLight)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FNColors.tan)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

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

    // MARK: - Share

    private static let appStoreURL = "https://apps.apple.com/us/app/front-nine/id6759806146"

    private func shareMessage(for profile: UserProfile) -> String {
        "Check out my golf course rankings on Front Nine! Find me at @\(profile.handle)\n\(Self.appStoreURL)"
    }

    // MARK: - Actions

    private func togglePrivacy() {
        isTogglingPrivacy = true
        Task {
            do {
                try await authService.togglePrivacy()
            } catch {
                errorMessage = "Could not update privacy setting. Please try again."
            }
            isTogglingPrivacy = false
        }
    }

    private func signOut() {
        do {
            try authService.signOut()
            followService.reset()
            if showDismissButton { dismiss() }
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    private func deleteAccount() {
        Task {
            do {
                try await authService.deleteAccount()
                followService.reset()
                if showDismissButton { dismiss() }
            } catch {
                errorMessage = "Could not delete account. Please sign out and sign back in, then try again."
            }
        }
    }

    // MARK: - Photo Actions

    private func handlePickedPhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await uploadPhoto(image)
    }

    private func uploadPhoto(_ image: UIImage) async {
        guard let uid = authService.userProfile?.uid else { return }
        do {
            let url = try await photoService.uploadPhoto(image, uid: uid)
            try await authService.updatePhotoURL(url)
        } catch {
            errorMessage = "Could not upload photo. Please try again."
        }
    }

    private func removePhoto() {
        guard let uid = authService.userProfile?.uid else { return }
        Task {
            do {
                try await photoService.deletePhoto(uid: uid)
                try await authService.updatePhotoURL(nil)
            } catch {
                errorMessage = "Could not remove photo. Please try again."
            }
        }
    }
}
