//
//  CourseDetailPreviewView.swift
//  Front Nine
//

import SwiftUI

struct CourseDetailPreviewView: View {
    let result: CourseSearchResult
    var existingCourse: Course?
    var onBack: () -> Void
    var onAddAndRate: () -> Void

    private var isRerank: Bool { existingCourse != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Search")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(FNColors.sage)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Course name
            Text(result.name)
                .font(FNFonts.header())
                .foregroundStyle(FNColors.text)
                .tracking(-0.5)
                .lineSpacing(2)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // Location
            HStack(spacing: 5) {
                Image(systemName: "mappin")
                    .font(.system(size: 12))

                Text(locationText)
                    .font(.system(size: 15))
            }
            .foregroundStyle(FNColors.textLight)
            .padding(.horizontal, 20)
            .padding(.top, 6)

            // Already ranked indicator
            if let course = existingCourse {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(FNColors.sage)

                    Text("Currently ranked #\(course.rankPosition) \u{2022} \(course.rating.label)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(FNColors.sage)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            // Divider
            Rectangle()
                .fill(FNColors.tan.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)

            // Action button
            Button(action: onAddAndRate) {
                Text(isRerank ? "Re-rank This Course" : "Add & Rate This Course")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isRerank ? FNColors.tan : FNColors.sage)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
    }

    private var locationText: String {
        Course.formatLocation(city: result.city, state: result.state, country: result.country)
    }
}
