//
//  RatingPickerView.swift
//  Front Nine
//

import SwiftUI

struct RatingPickerView: View {
    @Binding var selectedRating: Rating?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HOW WAS IT?")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            ForEach(Rating.allCases, id: \.self) { rating in
                RatingButton(
                    rating: rating,
                    isSelected: selectedRating == rating,
                    action: { selectedRating = rating }
                )
            }
        }
    }
}

// MARK: - Rating Button

private struct RatingButton: View {
    let rating: Rating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // Left color bar
                Rectangle()
                    .fill(rating.tierColor)
                    .frame(width: 4)

                // Label
                Text(rating.label)
                    .font(FNFonts.bodyMedium())
                    .foregroundStyle(FNColors.text)
                    .padding(16)

                Spacer()

                // Flag icon on the right
                FlagIcon(variant: rating.flagVariant, color: rating.tierColor)
                    .padding(.trailing, 16)
            }
            .background(
                isSelected
                    ? rating.tierColor.opacity(0.07)
                    : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? rating.tierColor : FNColors.tan,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Previews

#Preview("No selection") {
    @Previewable @State var rating: Rating? = nil
    RatingPickerView(selectedRating: $rating)
        .padding()
        .background(FNColors.cream)
}

#Preview("Liked selected") {
    @Previewable @State var rating: Rating? = .liked
    RatingPickerView(selectedRating: $rating)
        .padding()
        .background(FNColors.cream)
}
