//
//  OtherUserCourseRow.swift
//  Front Nine

import SwiftUI

/// Read-only course row for viewing another user's rankings. No swipe, no drag.
struct OtherUserCourseRow: View {
    let ranking: FirestoreRanking

    private var ratingEnum: Rating? {
        Rating(rawValue: ranking.rating)
    }

    private var tierColor: Color {
        ratingEnum?.tierColor ?? FNColors.warmGray
    }

    private var locationText: String {
        Course.formatLocation(city: ranking.city, state: ranking.state, country: ranking.country)
    }

    private var isHero: Bool { ranking.rankPosition == 1 }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Rank number with optional crown
            VStack(spacing: 2) {
                if isHero {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 6)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 4)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 6)
                    }
                }

                Text("\(ranking.rankPosition)")
                    .font(isHero ? FNFonts.heroRankNumber() : FNFonts.rankNumber())
                    .foregroundStyle(isHero ? tierColor : FNColors.tan)
            }
            .frame(width: 44, alignment: isHero ? .center : .leading)

            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [tierColor, tierColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: isHero ? 48 : 36)
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(ranking.name)
                    .font(isHero ? .system(size: 16, weight: .semibold) : FNFonts.bodyMedium())
                    .foregroundStyle(FNColors.text)

                Text(locationText)
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FNColors.tan)
        }
        .padding(.vertical, isHero ? 18 : 16)
        .contentShape(Rectangle())
    }
}
