//
//  QuickRateView.swift
//  Front Nine
//

import SwiftUI
import MapKit

struct QuickRateView: View {
    let searchResult: CourseSearchResult
    var existingCourse: Course?
    var enrichmentData: CourseEnrichmentData?
    var onCourseReady: (Course) -> Void
    var onBack: () -> Void

    @State private var courseType: CourseType? = .public
    @State private var holeCount: Int = 18
    @State private var selectedRating: Rating?
    @State private var notes: String = ""

    private var isRerank: Bool { existingCourse != nil }

    private var isValid: Bool {
        courseType != nil && selectedRating != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Map peek with back button overlay
                    ZStack(alignment: .topLeading) {
                        MapPeekView(
                            coordinate: searchResult.coordinate,
                            courseName: searchResult.name,
                            height: 120
                        )

                        Button(action: onBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(FNColors.sage)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.leading, 12)
                        .padding(.top, 12)
                    }

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

                    if let data = enrichmentData {
                        CourseStatsCard(
                            par: data.par,
                            courseRating: data.courseRating,
                            slope: data.slope,
                            totalYards: data.totalYards,
                            teeName: data.teeName
                        )
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
            } else if let holes = enrichmentData?.numberOfHoles {
                holeCount = holes
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

    private func applyEnrichment(to course: Course) {
        guard let data = enrichmentData else { return }
        course.par = data.par
        course.courseRating = data.courseRating
        course.slope = data.slope
        course.totalYards = data.totalYards
        course.golfCourseApiId = data.golfCourseApiId
        course.teeName = data.teeName
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
            course.latitude = searchResult.coordinate.latitude
            course.longitude = searchResult.coordinate.longitude
            applyEnrichment(to: course)
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
                country: searchResult.country.isEmpty ? nil : searchResult.country,
                latitude: searchResult.coordinate.latitude,
                longitude: searchResult.coordinate.longitude
            )
            course.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            applyEnrichment(to: course)
            onCourseReady(course)
        }
    }
}
