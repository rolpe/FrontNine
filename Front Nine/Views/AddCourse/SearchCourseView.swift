//
//  SearchCourseView.swift
//  Front Nine
//

import CoreLocation
import SwiftUI

struct SearchCourseView: View {
    @State private var viewModel = CourseSearchViewModel()
    @FocusState private var isSearchFocused: Bool

    let existingCourses: [Course]
    var onSelectResult: (CourseSearchResult) -> Void
    var onAddManually: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") { onCancel() }
                    .font(FNFonts.body())
                    .foregroundStyle(FNColors.sage)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Title
            Text("Add Course")
                .font(FNFonts.header())
                .foregroundStyle(FNColors.text)
                .tracking(-0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)

            // Search bar
            searchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Content
            ScrollView {
                if viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
                    emptyState
                } else if viewModel.isSearching {
                    searchingState
                } else if let error = viewModel.searchError {
                    errorState(error)
                } else if viewModel.results.isEmpty {
                    noResultsState
                } else {
                    resultsState
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                isSearchFocused = false
            }
        }
        .background(FNColors.cream)
        .task(id: viewModel.query) {
            let trimmed = viewModel.query.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                viewModel.results = []
                viewModel.isSearching = false
                viewModel.searchError = nil
                return
            }
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await viewModel.performSearch()
        }
        .task {
            await viewModel.loadNearbyIfAuthorized()
        }
        .onAppear {
            isSearchFocused = true
            viewModel.updateExistingCourses(existingCourses)
        }
        .onChange(of: existingCourses.count) {
            viewModel.updateExistingCourses(existingCourses)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(searchBarIconColor)

            TextField("Search by name, city, or state...", text: $viewModel.query)
                .font(FNFonts.body())
                .foregroundStyle(FNColors.text)
                .focused($isSearchFocused)
                .autocorrectionDisabled()

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                    isSearchFocused = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(FNColors.tan)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(searchBarBorderColor, lineWidth: 1.5)
        )
    }

    private var searchBarIconColor: Color {
        viewModel.query.isEmpty ? FNColors.tan : FNColors.sage
    }

    private var searchBarBorderColor: Color {
        viewModel.query.isEmpty ? FNColors.tan : FNColors.sage
    }

    // MARK: - States

    private var searchingState: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(FNColors.sage)

            Text("Searching courses...")
                .font(.system(size: 15))
                .foregroundStyle(FNColors.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var resultsState: some View {
        VStack(alignment: .leading, spacing: 0) {
            let count = viewModel.results.count
            Text("\(count) \(count == 1 ? "result" : "results")")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.5)
                .textCase(.uppercase)
                .padding(.bottom, 12)

            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                    CourseSearchResultRow(
                        result: result,
                        isAlreadyAdded: viewModel.isAlreadyAdded(result)
                    ) {
                        onSelectResult(result)
                    }

                    if index < viewModel.results.count - 1 {
                        Divider()
                            .background(FNColors.tan.opacity(0.2))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var noResultsState: some View {
        VStack(spacing: 4) {
            Text("No courses found")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(FNColors.text)

            Text("Try a different search or add manually")
                .font(.system(size: 14))
                .foregroundStyle(FNColors.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(FNFonts.body())
                .foregroundStyle(FNColors.text)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.performSearch() }
            } label: {
                Text("Try Again")
                    .font(FNFonts.bodyMedium())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(FNColors.coral)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(FNColors.coral.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(FNColors.coral.opacity(0.3), lineWidth: 1.5)
        )
        .padding(.horizontal, 20)
        .padding(.top, 48)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            // Recent searches
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("RECENT SEARCHES")
                        .font(FNFonts.label())
                        .foregroundStyle(FNColors.textLight)
                        .kerning(0.3)
                        .padding(.horizontal, 20)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { term in
                                Button {
                                    viewModel.query = term
                                } label: {
                                    Text(term)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(FNColors.text)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(FNColors.tan, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }

            // Nearby courses
            nearbySection

            // Add Manually card
            Button(action: onAddManually) {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FNColors.warmGray.opacity(0.1))
                        .frame(width: 42, height: 42)
                        .overlay {
                            Image(systemName: "pencil")
                                .font(.system(size: 16))
                                .foregroundStyle(FNColors.warmGray)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add Manually")
                            .font(FNFonts.bodyMedium())
                            .foregroundStyle(FNColors.text)

                        Text("Enter course details yourself")
                            .font(.system(size: 13))
                            .foregroundStyle(FNColors.textLight)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(FNColors.tan)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(FNColors.tan.opacity(0.2), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
    // MARK: - Nearby Section

    @ViewBuilder
    private var nearbySection: some View {
        let status = viewModel.locationManager.authorizationStatus

        if status == .notDetermined {
            // Prompt card
            Button {
                Task { await viewModel.requestNearbyPermission() }
            } label: {
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FNColors.sage.opacity(0.1))
                        .frame(width: 42, height: 42)
                        .overlay {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(FNColors.sage)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Nearby Courses")
                            .font(FNFonts.bodyMedium())
                            .foregroundStyle(FNColors.text)

                        Text("Find golf courses near you")
                            .font(.system(size: 13))
                            .foregroundStyle(FNColors.textLight)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(FNColors.tan)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(FNColors.tan.opacity(0.2), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            if viewModel.isLoadingNearby {
                VStack(spacing: 14) {
                    ProgressView()
                        .tint(FNColors.sage)
                    Text("Finding nearby courses...")
                        .font(.system(size: 15))
                        .foregroundStyle(FNColors.textLight)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else if let error = viewModel.nearbyError {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundStyle(FNColors.textLight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else if !viewModel.nearbyResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("NEARBY")
                        .font(FNFonts.label())
                        .foregroundStyle(FNColors.textLight)
                        .kerning(0.3)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.nearbyResults.enumerated()), id: \.element.id) { index, result in
                            CourseSearchResultRow(
                                result: result,
                                isAlreadyAdded: viewModel.isAlreadyAdded(result)
                            ) {
                                onSelectResult(result)
                            }

                            if index < viewModel.nearbyResults.count - 1 {
                                Divider()
                                    .background(FNColors.tan.opacity(0.2))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

        } else if status == .denied || status == .restricted {
            VStack(spacing: 12) {
                Text("Location access needed to find nearby courses.")
                    .font(.system(size: 14))
                    .foregroundStyle(FNColors.text)
                    .multilineTextAlignment(.center)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(FNFonts.bodyMedium())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(FNColors.sage)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(FNColors.sage.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(FNColors.sage.opacity(0.3), lineWidth: 1.5)
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    SearchCourseView(
        existingCourses: [],
        onSelectResult: { _ in },
        onAddManually: {},
        onCancel: {}
    )
}
