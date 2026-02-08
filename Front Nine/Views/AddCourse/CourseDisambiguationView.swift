//
//  CourseDisambiguationView.swift
//  Front Nine
//

import SwiftUI

/// Picker shown when the API returns multiple courses for the same club (e.g. Pinehurst).
struct CourseDisambiguationView: View {
    let candidates: [GolfCourseAPICourse]
    var onSelect: (GolfCourseAPICourse) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Multiple courses found")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            VStack(spacing: 0) {
                ForEach(candidates) { course in
                    Button(action: { onSelect(course) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.courseName)
                                    .font(FNFonts.bodyMedium())
                                    .foregroundStyle(FNColors.text)

                                if course.clubName != course.courseName {
                                    Text(course.clubName)
                                        .font(FNFonts.subtext())
                                        .foregroundStyle(FNColors.textLight)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(FNColors.tan)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)

                    if course.id != candidates.last?.id {
                        Divider()
                            .background(FNColors.tan.opacity(0.3))
                            .padding(.horizontal, 16)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(FNColors.tan, lineWidth: 1.5)
            )
        }
    }
}
