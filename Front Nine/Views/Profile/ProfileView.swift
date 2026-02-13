//
//  ProfileView.swift
//  Front Nine
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?

    private var memberSinceText: String {
        guard let profile = authService.userProfile else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: profile.createdAt))"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(FNColors.warmGray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 32) {
                    // Profile header
                    if let profile = authService.userProfile {
                        VStack(spacing: 8) {
                            // Avatar placeholder
                            Circle()
                                .fill(FNColors.sage.opacity(0.15))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text(initials(from: profile.displayName))
                                        .font(.system(size: 28, weight: .medium, design: .serif))
                                        .foregroundStyle(FNColors.sage)
                                )

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
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
        .confirmationDialog("Delete Account", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your profile. Your local rankings will not be affected.")
        }
    }

    // MARK: - Actions

    private func signOut() {
        do {
            try authService.signOut()
            dismiss()
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    private func deleteAccount() {
        Task {
            do {
                try await authService.deleteAccount()
                dismiss()
            } catch {
                errorMessage = "Could not delete account. Please sign out and sign back in, then try again."
            }
        }
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}
