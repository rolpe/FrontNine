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

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Rank number
            Text("\(ranking.rankPosition)")
                .font(FNFonts.rankNumber())
                .foregroundStyle(FNColors.tan)
                .frame(width: 44, alignment: .leading)

            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [tierColor, tierColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 36)
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(ranking.name)
                    .font(FNFonts.bodyMedium())
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
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}
