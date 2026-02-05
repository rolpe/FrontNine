//
//  TierSectionView.swift
//  Front Nine
//

import SwiftUI

struct TierHeaderView: View {
    let rating: Rating

    var body: some View {
        HStack(spacing: 6) {
            FlagIcon(variant: rating.flagVariant, color: rating.tierColor, size: 16)
            Text(rating.tierLabel)
                .font(FNFonts.label())
                .foregroundStyle(rating.tierColor)
                .kerning(0.5)
        }
        .textCase(nil)
        .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
    }
}
