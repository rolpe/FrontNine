//
//  CourseSearchResultRow.swift
//  Front Nine
//

import SwiftUI

struct CourseSearchResultRow: View {
    let result: CourseSearchResult
    var isAlreadyAdded: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Flag icon with optional checkmark overlay
                RoundedRectangle(cornerRadius: 10)
                    .fill(FNColors.tan.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay {
                        FlagIcon(variant: .outlined, color: FNColors.tan, size: 16)
                    }
                    .overlay(alignment: .topTrailing) {
                        if isAlreadyAdded {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(FNColors.sage)
                                .background(Circle().fill(Color.white).padding(1))
                                .offset(x: 4, y: -4)
                        }
                    }

                // Course info
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .font(FNFonts.bodyMedium())
                        .foregroundStyle(FNColors.text)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(locationText)
                        .font(FNFonts.label())
                        .foregroundStyle(FNColors.textLight)
                        .kerning(0)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(FNColors.tan)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var locationText: String {
        Course.formatLocation(city: result.city, state: result.state, country: result.country)
    }
}
