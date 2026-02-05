//
//  ComparisonView.swift
//  Front Nine
//

import SwiftUI

struct ComparisonView: View {
    let courseA: RankedCourse
    let courseB: RankedCourse
    let currentStep: Int
    let totalSteps: Int
    let onChoice: (ComparisonChoice) -> Void

    @State private var selected: ComparisonChoice?

    var body: some View {
        VStack(spacing: 0) {
            // Progress dots
            ProgressDotsView(currentStep: currentStep, totalSteps: totalSteps)
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
                    courseName: courseA.name,
                    courseLocation: "\(courseA.city), \(courseA.state)",
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
                    courseName: courseB.name,
                    courseLocation: "\(courseB.city), \(courseB.state)",
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

    private func choose(_ choice: ComparisonChoice) {
        guard selected == nil else { return }
        selected = choice
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onChoice(choice)
            selected = nil
        }
    }
}

#Preview {
    ComparisonView(
        courseA: RankedCourse(
            id: UUID(), name: "Whistling Straits",
            city: "Kohler", state: "WI",
            rating: .liked, rankPosition: 0
        ),
        courseB: RankedCourse(
            id: UUID(), name: "TPC Sawgrass",
            city: "Ponte Vedra Beach", state: "FL",
            rating: .liked, rankPosition: 4
        ),
        currentStep: 1,
        totalSteps: 3,
        onChoice: { _ in }
    )
}

#Preview("Long names") {
    ComparisonView(
        courseA: RankedCourse(
            id: UUID(), name: "Pebble Beach Golf Links",
            city: "Pebble Beach", state: "CA",
            rating: .loved, rankPosition: 0
        ),
        courseB: RankedCourse(
            id: UUID(), name: "Pinehurst No. 2 Resort & Country Club",
            city: "Pinehurst", state: "NC",
            rating: .loved, rankPosition: 1
        ),
        currentStep: 0,
        totalSteps: 2,
        onChoice: { _ in }
    )
}
