//
//  SocialCourseDetailView.swift
//  Front Nine

import SwiftUI
import SwiftData
import MapKit

/// Read-only course detail view built from another user's FirestoreRanking data.
struct SocialCourseDetailView: View {
    let ranking: FirestoreRanking
    let ownerName: String

    @Query(sort: \Course.rankPosition) private var localCourses: [Course]
    @State private var showingAddFlow = false

    private var matchingLocalCourse: Course? {
        let key = CourseSearchViewModel.courseKey(
            name: ranking.name, city: ranking.city, state: ranking.state
        )
        return localCourses.first { course in
            CourseSearchViewModel.courseKey(
                name: course.name, city: course.city, state: course.state
            ) == key
        }
    }

    private var locationText: String {
        Course.formatLocation(city: ranking.city, state: ranking.state, country: ranking.country)
    }

    private var hasCoordinates: Bool {
        if let lat = ranking.latitude, let lon = ranking.longitude {
            return lat != 0 || lon != 0
        }
        return false
    }

    private var hasEnrichedData: Bool {
        ranking.par != nil || ranking.courseRating != nil || ranking.slope != nil
    }

    private var ratingEnum: Rating? {
        Rating(rawValue: ranking.rating)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Map peek
                if hasCoordinates,
                   let lat = ranking.latitude,
                   let lon = ranking.longitude {
                    MapPeekView(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        courseName: ranking.name,
                        height: 160
                    )
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Course name + pills
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(ranking.name)
                                .font(.system(size: 26, weight: .semibold, design: .serif))
                                .foregroundStyle(FNColors.text)
                                .lineSpacing(2)

                            if let courseType = CourseType(rawValue: ranking.courseType) {
                                TypePill(courseType: courseType)
                            }
                            HolesPill(holeCount: ranking.holeCount)
                        }

                        Text(locationText)
                            .font(.system(size: 17))
                            .foregroundStyle(FNColors.textLight)
                    }

                    // "On your list" indicator
                    if let localCourse = matchingLocalCourse {
                        yourRankIndicator(localCourse)
                    }

                    // Rank + Rating cards (the other user's rank/rating)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ranked by \(ownerName)")
                            .font(FNFonts.label())
                            .foregroundStyle(FNColors.textLight)
                            .kerning(0.3)

                        HStack(spacing: 12) {
                            rankCard
                            ratingCard
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }

                    // Course stats
                    if hasEnrichedData {
                        CourseStatsCard(
                            par: ranking.par,
                            courseRating: ranking.courseRating,
                            slope: ranking.slope,
                            totalYards: ranking.totalYards,
                            teeName: ranking.teeName
                        )
                    }

                    // Notes with attribution
                    if let notes = ranking.notes, !notes.isEmpty {
                        notesSection(notes)
                    }

                    // "Add to My Rankings" CTA (only if not already in your list)
                    if matchingLocalCourse == nil {
                        addToRankingsButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(FNColors.cream)
        .navigationTitle(ranking.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddFlow) {
            AddCourseFlowView(preselectedResult: buildSearchResult())
        }
    }

    // MARK: - Your Rank Indicator

    private func yourRankIndicator(_ course: Course) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(course.rating.tierColor)
                .frame(width: 10, height: 10)

            Text("#\(course.rankPosition) on your list")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(FNColors.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FNColors.tan.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Cards

    private var rankCard: some View {
        VStack(spacing: 6) {
            Text("RANK")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            Text("#\(ranking.rankPosition)")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
    }

    private var ratingCard: some View {
        let rating = ratingEnum ?? .liked
        let color = rating.tierColor
        return VStack(spacing: 6) {
            Text("RATING")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            FlagIcon(
                variant: rating.flagVariant,
                color: color,
                size: 32
            )
            .padding(.vertical, 2)

            Text(rating.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 1.5)
        )
    }

    // MARK: - Notes

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            Text(notes)
                .font(.system(size: 16))
                .foregroundStyle(FNColors.text)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FNColors.tan, lineWidth: 1.5)
                )
        }
    }

    // MARK: - Add to Rankings

    private var addToRankingsButton: some View {
        Button {
            showingAddFlow = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("Add to My Rankings")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(FNColors.sage)
            )
        }
    }

    // MARK: - Helpers

    private func buildSearchResult() -> CourseSearchResult {
        CourseSearchResult(
            id: "\(ranking.name)|\(ranking.latitude ?? 0)|\(ranking.longitude ?? 0)",
            name: ranking.name,
            city: ranking.city,
            state: ranking.state,
            country: ranking.country ?? "",
            coordinate: CLLocationCoordinate2D(
                latitude: ranking.latitude ?? 0,
                longitude: ranking.longitude ?? 0
            )
        )
    }
}
