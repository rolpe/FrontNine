//
//  ComparisonViewModel.swift
//  Front Nine
//

import Foundation

@Observable
final class ComparisonViewModel: Identifiable {
    let id = UUID()
    let newCourse: Course
    private let tierCourses: [RankedCourse]
    private let allCourses: [RankedCourse]

    private(set) var lowIndex: Int = 0
    private(set) var highIndex: Int
    private(set) var currentStep: Int = 0

    /// Whether the tier has existing courses that require comparisons.
    var needsComparisons: Bool { !tierCourses.isEmpty }

    var totalSteps: Int {
        RankingEngine.expectedComparisons(tierSize: tierCourses.count)
    }

    var isComplete: Bool {
        lowIndex > highIndex
    }

    /// The existing course to compare against in the current step, or nil if done.
    var comparisonCourse: RankedCourse? {
        guard let midIndex = RankingEngine.nextComparisonIndex(
            lowIndex: lowIndex, highIndex: highIndex
        ) else { return nil }
        return tierCourses[midIndex]
    }

    /// The new course as a RankedCourse value (for display in ComparisonView).
    var newCourseAsRanked: RankedCourse {
        RankedCourse(
            id: newCourse.id, name: newCourse.name,
            city: newCourse.city, state: newCourse.state,
            country: newCourse.country,
            rating: newCourse.rating, rankPosition: 0,
            latitude: newCourse.latitude, longitude: newCourse.longitude
        )
    }

    init(newCourse: Course, existingCourses: [Course]) {
        self.newCourse = newCourse
        self.allCourses = existingCourses.map {
            RankedCourse(
                id: $0.id, name: $0.name,
                city: $0.city, state: $0.state,
                country: $0.country,
                rating: $0.rating, rankPosition: $0.rankPosition,
                latitude: $0.latitude, longitude: $0.longitude
            )
        }
        self.tierCourses = RankingEngine.coursesInTier(
            rating: newCourse.rating, allCourses: self.allCourses
        )
        self.highIndex = self.tierCourses.count - 1
    }

    func choose(_ choice: ComparisonChoice) {
        guard let midIndex = RankingEngine.nextComparisonIndex(
            lowIndex: lowIndex, highIndex: highIndex
        ) else { return }

        switch choice {
        case .preferA:
            highIndex = midIndex - 1
        case .preferB:
            lowIndex = midIndex + 1
        case .cantDecide:
            let randomIdx = Int.random(in: lowIndex...(highIndex + 1))
            lowIndex = randomIdx
            highIndex = randomIdx - 1
        }

        currentStep += 1
    }

    /// The global rank position where the new course should be inserted.
    var finalRank: Int {
        if tierCourses.isEmpty {
            return RankingEngine.emptyTierInsertionRank(
                for: newCourse.rating, allCourses: allCourses
            )
        }
        return RankingEngine.globalRankForInsertion(
            insertionIndex: lowIndex, tierCourses: tierCourses
        )
    }

    /// Rank updates needed for existing courses that must shift down.
    var rankShifts: [UUID: Int] {
        RankingEngine.shiftRanksForInsertion(
            insertAtRank: finalRank, allCourses: allCourses
        )
    }
}
