//
//  ComparisonView.swift
//  Front Nine
//

import SwiftUI

struct ComparisonView: View {
    let viewModel: ComparisonViewModel
    let onComplete: () -> Void

    @State private var selected: ComparisonChoice?

    var body: some View {
        if let compareCourse = viewModel.comparisonCourse {
            VStack(spacing: 0) {
                // Progress dots
                ProgressDotsView(
                    currentStep: viewModel.currentStep,
                    totalSteps: viewModel.totalSteps
                )
                .padding(.top, 20)
                .padding(.bottom, 12)

                // Question
                VStack(spacing: 8) {
                    Text("Which would you\nrather play?")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(FNColors.text)
                        .multilineTextAlignment(.center)
                        .tracking(-0.3)

                    Text("Tap your choice")
                        .font(.system(size: 15))
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.bottom, 32)

                // Cards + OR divider
                VStack(spacing: 16) {
                    ComparisonCardView(
                        courseName: viewModel.newCourse.name,
                        courseLocation: "\(viewModel.newCourse.city), \(viewModel.newCourse.state)",
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
                        courseLocation: "\(compareCourse.city), \(compareCourse.state)",
                        isSelected: selected == .preferB,
                        action: { choose(.preferB) }
                    )
                }
                .padding(.horizontal, 16)

                Spacer()

                // Can't decide
                Button {
                    choose(.cantDecide)
                } label: {
                    Text("I can't decide")
                        .font(.system(size: 15))
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FNColors.cream)
        }
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
        courseType: .public, rating: .liked
    )
    let existing = [
        Course(name: "TPC Sawgrass", city: "Ponte Vedra Beach", state: "FL",
               courseType: .public, rating: .liked, rankPosition: 1),
        Course(name: "Bethpage Black", city: "Farmingdale", state: "NY",
               courseType: .public, rating: .liked, rankPosition: 2),
        Course(name: "Torrey Pines South", city: "La Jolla", state: "CA",
               courseType: .public, rating: .liked, rankPosition: 3),
    ]
    let vm = ComparisonViewModel(newCourse: course, existingCourses: existing)
    ComparisonView(viewModel: vm, onComplete: {})
}
