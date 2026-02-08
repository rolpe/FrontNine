//
//  QuickRateView.swift
//  Front Nine
//

import SwiftUI

struct QuickRateView: View {
    let searchResult: CourseSearchResult
    var existingCourse: Course?
    var onCourseReady: (Course) -> Void
    var onBack: () -> Void

    @State private var courseType: CourseType?
    @State private var holeCount: Int = 18
    @State private var selectedRating: Rating?
    @State private var notes: String = ""

    private var isRerank: Bool { existingCourse != nil }

    private var isValid: Bool {
        courseType != nil && selectedRating != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(FNColors.sage)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Course info header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(searchResult.name)
                            .font(FNFonts.header())
                            .foregroundStyle(FNColors.text)
                            .tracking(-0.5)

                        Text(locationText)
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.textLight)
                    }

                    Divider()
                        .background(FNColors.tan.opacity(0.25))

                    // Course type
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

                    // Holes
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

                    // Rating
                    RatingPickerView(selectedRating: $selectedRating)

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(FNFonts.label())
                            .foregroundStyle(FNColors.textLight)
                            .kerning(0.3)

                        TextField("Optional notes...", text: $notes, axis: .vertical)
                            .font(FNFonts.body())
                            .foregroundStyle(FNColors.text)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FNColors.tan, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider().background(FNColors.tan.opacity(0.25))

                    Button(action: submitCourse) {
                        Text(isRerank ? "Re-rank" : "Add to Rankings")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isValid ? .white : FNColors.textLight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(buttonColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .animation(.easeInOut(duration: 0.2), value: selectedRating)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(FNColors.cream)
            }
        }
        .background(FNColors.cream)
        .onAppear {
            if let course = existingCourse {
                courseType = course.courseType
                holeCount = course.holeCount
                selectedRating = course.rating
                notes = course.notes ?? ""
            }
        }
    }

    private var locationText: String {
        Course.formatLocation(city: searchResult.city, state: searchResult.state, country: searchResult.country)
    }

    private var buttonColor: Color {
        guard isValid, let rating = selectedRating else {
            return FNColors.tan
        }
        return rating.tierColor
    }

    private func submitCourse() {
        guard let courseType, let selectedRating else { return }
        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)

        if let course = existingCourse {
            // Re-rank: update the existing course in place
            course.courseType = courseType
            course.holeCount = holeCount
            course.rating = selectedRating
            course.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            course.updatedAt = Date()
            onCourseReady(course)
        } else {
            // New course
            let course = Course(
                name: searchResult.name,
                city: searchResult.city,
                state: searchResult.state,
                courseType: courseType,
                holeCount: holeCount,
                rating: selectedRating,
                rankPosition: 0,
                country: searchResult.country.isEmpty ? nil : searchResult.country
            )
            course.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            onCourseReady(course)
        }
    }
}
