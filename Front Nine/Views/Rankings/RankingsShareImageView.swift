//
//  RankingsShareImageView.swift
//  Front Nine

import SwiftUI

/// A SwiftUI view designed to be rendered as a shareable image via ImageRenderer.
/// Not displayed in the app UI — only used for export.
struct RankingsShareImageView: View {
    let displayName: String
    let handle: String
    let courses: [Course]

    private static let maxCourses = 10

    private var visibleCourses: [Course] {
        Array(courses.sorted { $0.rankPosition < $1.rankPosition }.prefix(Self.maxCourses))
    }

    private var remainingCount: Int {
        max(0, courses.count - Self.maxCourses)
    }

    private var lovedCourses: [Course] {
        visibleCourses.filter { $0.rating == .loved }
    }

    private var likedCourses: [Course] {
        visibleCourses.filter { $0.rating == .liked }
    }

    private var dislikedCourses: [Course] {
        visibleCourses.filter { $0.rating == .disliked }
    }

    // 4:5 aspect ratio (Instagram max portrait)
    private static let imageWidth: CGFloat = 360
    private static let minImageHeight: CGFloat = 360 * (5.0 / 4.0) // 450pt

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.bottom, 16)

            // Tier sections
            if !lovedCourses.isEmpty {
                tierSection(rating: .loved, courses: lovedCourses)
            }
            if !likedCourses.isEmpty {
                tierSection(rating: .liked, courses: likedCourses)
                    .padding(.top, lovedCourses.isEmpty ? 0 : 12)
            }
            if !dislikedCourses.isEmpty {
                tierSection(rating: .disliked, courses: dislikedCourses)
                    .padding(.top, (lovedCourses.isEmpty && likedCourses.isEmpty) ? 0 : 12)
            }

            // "And X more" teaser
            if remainingCount > 0 {
                Text("and \(remainingCount) more \(remainingCount == 1 ? "course" : "courses") ranked")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundStyle(FNColors.warmGray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
            }

            Spacer(minLength: 20)

            // Footer
            footer
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 48)
        .frame(width: Self.imageWidth)
        .frame(minHeight: Self.minImageHeight)
        .background(FNColors.cream)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Front Nine")
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.sage)

            Text("My Golf Course Rankings")
                .font(.system(size: 19, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)

            Text("@\(handle)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(FNColors.warmGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(FNColors.tan)
                .frame(height: 1)
        }
    }

    // MARK: - Tier Section

    private func tierSection(rating: Rating, courses: [Course]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Tier header
            HStack(spacing: 5) {
                FlagIcon(variant: rating.flagVariant, color: rating.tierColor, size: 10)

                Text(rating.tierLabel)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(rating.tierColor)
                    .kerning(1.2)

                LinearGradient(
                    colors: [rating.tierColor.opacity(0.2), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
            }

            // Course rows
            ForEach(courses, id: \.id) { course in
                courseRow(course: course)
            }
        }
    }

    private func courseRow(course: Course) -> some View {
        HStack(alignment: .center, spacing: 0) {
            // Rank number
            VStack(spacing: 1) {
                if course.rankPosition == 1 {
                    HStack(spacing: 1.5) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 1.5, height: 4)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 1.5, height: 2.5)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 1.5, height: 4)
                    }
                }

                Text("\(course.rankPosition)")
                    .font(course.rankPosition == 1
                        ? .system(size: 22, weight: .light, design: .serif)
                        : .system(size: 17, weight: .light, design: .serif))
                    .foregroundStyle(course.rankPosition == 1 ? course.rating.tierColor : FNColors.tan)
            }
            .frame(width: 30, alignment: course.rankPosition == 1 ? .center : .leading)

            // Tier color bar
            RoundedRectangle(cornerRadius: 1.5)
                .fill(
                    LinearGradient(
                        colors: [course.rating.tierColor, course.rating.tierColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 2.5, height: course.rankPosition == 1 ? 32 : 24)
                .padding(.trailing, 8)

            // Course info
            VStack(alignment: .leading, spacing: 1) {
                Text(course.name)
                    .font(.system(size: 12, weight: course.rankPosition == 1 ? .semibold : .medium))
                    .foregroundStyle(FNColors.text)
                    .lineLimit(1)

                Text(course.locationText)
                    .font(.system(size: 9.5))
                    .foregroundStyle(FNColors.textLight)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, 3)
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 3) {
            Rectangle()
                .fill(FNColors.tan)
                .frame(height: 1)
                .padding(.bottom, 3)

            Text("Download Front Nine on the App Store")
                .font(.system(size: 9))
                .foregroundStyle(FNColors.warmGray)
        }
        .frame(maxWidth: .infinity)
    }
}
