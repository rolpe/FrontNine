//
//  CourseFormFields.swift
//  Front Nine

import SwiftUI

/// Reusable form fields for creating or editing a course.
/// Does not include navigation chrome, submit buttons, or scroll wrapping.
struct CourseFormFields: View {
    @Binding var name: String
    @Binding var city: String
    @Binding var state: String
    @Binding var country: String
    @Binding var courseType: CourseType?
    @Binding var holeCount: Int
    @Binding var rating: Rating?
    @Binding var notes: String

    var namePlaceholder: String = "Course name"
    var showDividerBeforeRating: Bool = false
    var showRating: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            FNTextField(
                label: "Course Name",
                placeholder: namePlaceholder,
                text: $name,
                characterLimit: 100
            )

            HStack(alignment: .top, spacing: 12) {
                FNTextField(
                    label: "City",
                    placeholder: "City",
                    text: $city,
                    characterLimit: 50
                )
                .frame(maxWidth: .infinity)

                FNTextField(
                    label: "State / Region",
                    placeholder: "e.g. CA",
                    text: $state,
                    characterLimit: 50
                )
                .frame(width: 120)
            }

            FNTextField(
                label: "Country",
                placeholder: "e.g. United States",
                text: $country,
                characterLimit: 50
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("COURSE TYPE")
                    .font(FNFonts.label())
                    .foregroundStyle(FNColors.textLight)
                    .kerning(0.3)
                HStack(spacing: 8) {
                    ForEach(CourseType.allCases, id: \.self) { type in
                        PillButtonView(
                            title: type.rawValue,
                            isSelected: courseType == type,
                            action: { courseType = type }
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("HOLES")
                    .font(FNFonts.label())
                    .foregroundStyle(FNColors.textLight)
                    .kerning(0.3)
                HStack(spacing: 8) {
                    PillButtonView(
                        title: "9",
                        isSelected: holeCount == 9,
                        action: { holeCount = 9 }
                    )
                    PillButtonView(
                        title: "18",
                        isSelected: holeCount == 18,
                        action: { holeCount = 18 }
                    )
                }
            }

            if showRating {
                if showDividerBeforeRating {
                    Divider()
                        .background(FNColors.tan)
                        .padding(.vertical, 8)
                }

                RatingPickerView(selectedRating: $rating)
            }

            FNTextField(
                label: "Notes (optional)",
                placeholder: "Any thoughts about this course...",
                text: $notes,
                characterLimit: 280
            )
        }
    }
}
