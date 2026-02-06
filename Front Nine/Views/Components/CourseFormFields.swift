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
    @Binding var courseType: CourseType?
    @Binding var holeCount: Int
    @Binding var rating: Rating?
    @Binding var notes: String

    var namePlaceholder: String = "Course name"
    var showDividerBeforeRating: Bool = false

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

                VStack(alignment: .leading, spacing: 8) {
                    Text("STATE")
                        .font(FNFonts.label())
                        .foregroundStyle(FNColors.textLight)
                        .kerning(0.3)

                    Picker("State", selection: $state) {
                        Text("--").tag("")
                        ForEach(USState.allCases) { st in
                            Text(st.rawValue).tag(st.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(FNColors.tan, lineWidth: 1.5)
                    )
                }
                .frame(width: 100)
            }

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

            if showDividerBeforeRating {
                Divider()
                    .background(FNColors.tan)
                    .padding(.vertical, 8)
            }

            RatingPickerView(selectedRating: $rating)

            FNTextField(
                label: "Notes (optional)",
                placeholder: "Any thoughts about this course...",
                text: $notes,
                characterLimit: 280
            )
        }
    }
}
