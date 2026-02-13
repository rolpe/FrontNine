//
//  ProfileSetupView.swift
//  Front Nine
//

import SwiftUI

struct ProfileSetupView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileSetupViewModel?

    var body: some View {
        if let viewModel {
            profileForm(viewModel: viewModel)
        } else {
            Color.clear.onAppear {
                // Pre-fill display name from Apple credential if available
                let name = authService.currentUserDisplayName ?? ""
                viewModel = ProfileSetupViewModel(authService: authService, initialName: name)
            }
        }
    }

    private func profileForm(viewModel: ProfileSetupViewModel) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Set Up Your Profile")
                            .font(.system(size: 28, weight: .semibold, design: .serif))
                            .foregroundStyle(FNColors.text)

                        Text("Choose a display name and unique handle.")
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.textLight)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)

                    // Display name
                    FNTextField(
                        label: "Display Name",
                        placeholder: "Your name",
                        text: Bindable(viewModel).displayName,
                        characterLimit: 50
                    )

                    // Handle field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HANDLE")
                            .font(FNFonts.label())
                            .foregroundStyle(FNColors.textLight)
                            .kerning(0.3)

                        HStack(spacing: 0) {
                            Text("@")
                                .font(FNFonts.body())
                                .foregroundStyle(FNColors.textLight)
                                .padding(.leading, 14)

                            TextField("username", text: Bindable(viewModel).handle)
                                .font(FNFonts.body())
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.vertical, 14)
                                .padding(.trailing, 14)
                                .onChange(of: viewModel.handle) {
                                    viewModel.handleDidChange()
                                }

                            // Status indicator
                            handleStatusIcon(viewModel.handleStatus)
                                .padding(.trailing, 14)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(handleBorderColor(viewModel.handleStatus), lineWidth: 1.5)
                        )

                        // Status message
                        handleStatusMessage(viewModel.handleStatus)
                    }

                    // Error message
                    if let error = viewModel.saveError {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(FNColors.coral)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.immediately)

            // Save button
            Button {
                Task { await viewModel.save() }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Save & Continue")
                    }
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isValid ? FNColors.sage : FNColors.warmGray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isValid || viewModel.isSaving)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
    }

    // MARK: - Handle Status Helpers

    @ViewBuilder
    private func handleStatusIcon(_ status: HandleStatus) -> some View {
        switch status {
        case .empty, .tooShort, .invalid:
            EmptyView()
        case .checking:
            ProgressView()
                .scaleEffect(0.8)
        case .available:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(FNColors.sage)
        case .taken:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(FNColors.coral)
        }
    }

    private func handleBorderColor(_ status: HandleStatus) -> Color {
        switch status {
        case .available: FNColors.sage
        case .taken, .invalid: FNColors.coral
        default: FNColors.tan
        }
    }

    @ViewBuilder
    private func handleStatusMessage(_ status: HandleStatus) -> some View {
        switch status {
        case .empty:
            Text("3\u{2013}30 characters: lowercase letters, numbers, underscores")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.textLight)
        case .tooShort:
            Text("Handle must be at least 3 characters")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.coral)
        case .invalid:
            Text("Only lowercase letters, numbers, and underscores allowed")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.coral)
        case .checking:
            Text("Checking availability\u{2026}")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.textLight)
        case .available:
            Text("Handle is available")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.sage)
        case .taken:
            Text("This handle is already taken")
                .font(.system(size: 12))
                .foregroundStyle(FNColors.coral)
        }
    }
}
