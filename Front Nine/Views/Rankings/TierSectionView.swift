//
//  TierSectionView.swift
//  Front Nine
//

import SwiftUI

struct TierHeaderView: View {
    let rating: Rating
    var count: Int = 0

    var body: some View {
        HStack(spacing: 8) {
            // Flag accent
            FlagIcon(variant: rating.flagVariant, color: rating.tierColor, size: 14)

            // Tier label
            Text(rating.tierLabel)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(rating.tierColor)
                .kerning(1.5)

            // Fading gradient line
            LinearGradient(
                colors: [rating.tierColor.opacity(0.2), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)

            // Count
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(rating.tierColor.opacity(0.5))
            }
        }
        .textCase(nil)
    }
}
