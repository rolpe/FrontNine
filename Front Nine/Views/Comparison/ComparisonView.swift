//
//  ComparisonView.swift
//  Front Nine
//

import SwiftUI
import MapKit

struct ComparisonView: View {
    let viewModel: ComparisonViewModel
    let onComplete: () -> Void

    @State private var selected: ComparisonChoice?

    private var tierColor: Color {
        viewModel.newCourse.rating.tierColor
    }

    var body: some View {
        if let compareCourse = viewModel.comparisonCourse {
            VStack(spacing: 0) {
                // Map peek (when both courses have coordinates)
                if let coordA = coordinate(for: viewModel.newCourse),
                   let coordB = coordinate(lat: compareCourse.latitude, lon: compareCourse.longitude) {
                    ComparisonMapView(
                        coordinateA: coordA,
                        coordinateB: coordB,
                        nameA: viewModel.newCourse.name,
                        nameB: compareCourse.name
                    )
                    .id(compareCourse.id)
                }

                // Progress dots (tinted to tier color)
                ProgressDotsView(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps,
                    activeColor: tierColor
                )
                .padding(.top, 24)
                .padding(.bottom, 12)

                // Question
                VStack(spacing: 8) {
                    Text("Which would you\nrather play?")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(FNColors.text)
                        .multilineTextAlignment(.center)
                        .tracking(-0.3)
                }
                .padding(.bottom, 32)

                // Cards + OR divider
                VStack(spacing: 16) {
                    ComparisonCardView(
                        courseName: viewModel.newCourse.name,
                        courseLocation: viewModel.newCourse.locationText,
                        isSelected: selected == .preferA,
                        action: { choose(.preferA) }
                    )

                    // OR divider
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(FNColors.tan)
                            .frame(height: 1)

                        Text("OR")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(FNColors.tan)
                            .kerning(1)

                        Rectangle()
                            .fill(FNColors.tan)
                            .frame(height: 1)
                    }

                    ComparisonCardView(
                        courseName: compareCourse.name,
                        courseLocation: Course.formatLocation(city: compareCourse.city, state: compareCourse.state, country: compareCourse.country),
                        isSelected: selected == .preferB,
                        action: { choose(.preferB) }
                    )
                }
                .padding(.horizontal, 16)

                // Can't decide
                Button {
                    choose(.cantDecide)
                } label: {
                    Text("I can't decide")
                        .font(.system(size: 15))
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.top, 32)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FNColors.cream)
        }
    }

    private func coordinate(for course: Course) -> CLLocationCoordinate2D? {
        guard let lat = course.latitude, let lon = course.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func coordinate(lat: Double?, lon: Double?) -> CLLocationCoordinate2D? {
        guard let lat, let lon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func choose(_ choice: ComparisonChoice) {
        guard selected == nil else { return }
        selected = choice
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            viewModel.choose(choice)
            selected = nil
            if viewModel.isComplete {
                onComplete()
            }
        }
    }
}

#Preview {
    let course = Course(
        name: "Whistling Straits", city: "Kohler", state: "WI",
        courseType: .public, rating: .liked,
        latitude: 43.8531, longitude: -87.7272
    )
    let existing = [
        Course(name: "TPC Sawgrass", city: "Ponte Vedra Beach", state: "FL",
               courseType: .public, rating: .liked, rankPosition: 1,
               latitude: 30.1975, longitude: -81.3942),
        Course(name: "Bethpage Black", city: "Farmingdale", state: "NY",
               courseType: .public, rating: .liked, rankPosition: 2,
               latitude: 40.7445, longitude: -73.4539),
        Course(name: "Torrey Pines South", city: "La Jolla", state: "CA",
               courseType: .public, rating: .liked, rankPosition: 3,
               latitude: 32.8998, longitude: -117.2523),
    ]
    let vm = ComparisonViewModel(newCourse: course, existingCourses: existing)
    ComparisonView(viewModel: vm, onComplete: {})
}
