//
//  ComparisonCardView.swift
//  Front Nine
//

import SwiftUI

struct ComparisonCardView: View {
    let courseName: String
    let courseLocation: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(courseName)
                    .font(FNFonts.cardTitle())
                    .foregroundStyle(isSelected ? .white : FNColors.text)
                    .multilineTextAlignment(.center)

                Text(courseLocation)
                    .font(FNFonts.cardSubtitle())
                    .foregroundStyle(
                        isSelected
                            ? .white.opacity(0.85)
                            : FNColors.textLight
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(isSelected ? FNColors.sage : .white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? FNColors.sage : FNColors.tan,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected
                    ? FNColors.sage.opacity(0.3)
                    : .black.opacity(0.04),
                radius: isSelected ? 10 : 4,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

#Preview("Unselected") {
    ComparisonCardView(
        courseName: "Whistling Straits",
        courseLocation: "Kohler, WI",
        isSelected: false,
        action: {}
    )
    .padding()
    .background(FNColors.cream)
}

#Preview("Selected") {
    ComparisonCardView(
        courseName: "TPC Sawgrass",
        courseLocation: "Ponte Vedra Beach, FL",
        isSelected: true,
        action: {}
    )
    .padding()
    .background(FNColors.cream)
}

#Preview("Long name") {
    ComparisonCardView(
        courseName: "Pebble Beach Golf Links at Spanish Bay",
        courseLocation: "Pebble Beach, CA",
        isSelected: false,
        action: {}
    )
    .padding()
    .background(FNColors.cream)
}
