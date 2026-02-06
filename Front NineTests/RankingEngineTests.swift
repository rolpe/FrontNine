//
//  RankingEngineTests.swift
//  Front NineTests
//

import Foundation
import Testing
@testable import Front_Nine

struct RankingEngineTests {

    // MARK: - Helpers

    private func makeCourse(
        name: String = "Test",
        rating: Rating,
        rank: Int
    ) -> RankedCourse {
        RankedCourse(
            id: UUID(), name: name, city: "City", state: "CA",
            rating: rating, rankPosition: rank
        )
    }

    // MARK: - expectedComparisons

    @Test func zeroCoursesInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 0) == 0)
    }

    @Test func oneCourseInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 1) == 1)
    }

    @Test func twoCourseInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 2) == 2)
    }

    @Test func threeCoursesInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 3) == 2)
    }

    @Test func fourCoursesInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 4) == 3)
    }

    @Test func sevenCoursesInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 7) == 3)
    }

    @Test func eightCoursesInTier() {
        #expect(RankingEngine.expectedComparisons(tierSize: 8) == 4)
    }

    // MARK: - coursesInTier

    @Test func filtersAndSortsByTier() {
        let courses = [
            makeCourse(name: "C", rating: .liked, rank: 5),
            makeCourse(name: "A", rating: .loved, rank: 1),
            makeCourse(name: "D", rating: .liked, rank: 6),
            makeCourse(name: "B", rating: .loved, rank: 2),
        ]

        let loved = RankingEngine.coursesInTier(rating: .loved, allCourses: courses)
        #expect(loved.count == 2)
        #expect(loved[0].name == "A")
        #expect(loved[1].name == "B")

        let liked = RankingEngine.coursesInTier(rating: .liked, allCourses: courses)
        #expect(liked.count == 2)
        #expect(liked[0].name == "C")
        #expect(liked[1].name == "D")
    }

    @Test func emptyTierReturnsEmpty() {
        let courses = [
            makeCourse(rating: .loved, rank: 1),
        ]
        let disliked = RankingEngine.coursesInTier(rating: .disliked, allCourses: courses)
        #expect(disliked.isEmpty)
    }

    // MARK: - emptyTierInsertionRank

    @Test func emptyLovedTierInsertsAtOne() {
        let rank = RankingEngine.emptyTierInsertionRank(for: .loved, allCourses: [])
        #expect(rank == 1)
    }

    @Test func emptyLikedTierInsertsAfterLoved() {
        let courses = [
            makeCourse(rating: .loved, rank: 1),
            makeCourse(rating: .loved, rank: 2),
        ]
        let rank = RankingEngine.emptyTierInsertionRank(for: .liked, allCourses: courses)
        #expect(rank == 3)
    }

    @Test func emptyDislikedTierInsertsAfterAll() {
        let courses = [
            makeCourse(rating: .loved, rank: 1),
            makeCourse(rating: .liked, rank: 2),
            makeCourse(rating: .liked, rank: 3),
        ]
        let rank = RankingEngine.emptyTierInsertionRank(for: .disliked, allCourses: courses)
        #expect(rank == 4)
    }

    @Test func emptyLikedTierBetweenLovedAndDisliked() {
        let courses = [
            makeCourse(rating: .loved, rank: 1),
            makeCourse(rating: .disliked, rank: 2),
        ]
        let rank = RankingEngine.emptyTierInsertionRank(for: .liked, allCourses: courses)
        #expect(rank == 2)
    }

    // MARK: - nextComparisonIndex

    @Test func middleOfRange() {
        #expect(RankingEngine.nextComparisonIndex(lowIndex: 0, highIndex: 4) == 2)
    }

    @Test func singleElementRange() {
        #expect(RankingEngine.nextComparisonIndex(lowIndex: 2, highIndex: 2) == 2)
    }

    @Test func exhaustedRange() {
        #expect(RankingEngine.nextComparisonIndex(lowIndex: 3, highIndex: 2) == nil)
    }

    @Test func twoElementRange() {
        #expect(RankingEngine.nextComparisonIndex(lowIndex: 0, highIndex: 1) == 0)
    }

    // MARK: - globalRankForInsertion

    @Test func insertAtStartOfTier() {
        let tier = [
            makeCourse(rating: .liked, rank: 3),
            makeCourse(rating: .liked, rank: 4),
        ]
        let rank = RankingEngine.globalRankForInsertion(insertionIndex: 0, tierCourses: tier)
        #expect(rank == 3)
    }

    @Test func insertAtEndOfTier() {
        let tier = [
            makeCourse(rating: .liked, rank: 3),
            makeCourse(rating: .liked, rank: 4),
        ]
        let rank = RankingEngine.globalRankForInsertion(insertionIndex: 2, tierCourses: tier)
        #expect(rank == 5)
    }

    @Test func insertInMiddleOfTier() {
        let tier = [
            makeCourse(rating: .liked, rank: 3),
            makeCourse(rating: .liked, rank: 4),
            makeCourse(rating: .liked, rank: 5),
        ]
        let rank = RankingEngine.globalRankForInsertion(insertionIndex: 1, tierCourses: tier)
        #expect(rank == 4)
    }

    @Test func insertIntoEmptyTier() {
        let rank = RankingEngine.globalRankForInsertion(insertionIndex: 0, tierCourses: [])
        #expect(rank == 1)
    }

    // MARK: - shiftRanksForInsertion

    @Test func shiftsCoursesAtAndBelowInsertionPoint() {
        let a = makeCourse(name: "A", rating: .loved, rank: 1)
        let b = makeCourse(name: "B", rating: .loved, rank: 2)
        let c = makeCourse(name: "C", rating: .liked, rank: 3)

        let shifts = RankingEngine.shiftRanksForInsertion(
            insertAtRank: 2, allCourses: [a, b, c]
        )

        #expect(shifts[a.id] == nil) // rank 1, not shifted
        #expect(shifts[b.id] == 3)   // rank 2 -> 3
        #expect(shifts[c.id] == 4)   // rank 3 -> 4
    }

    @Test func noShiftsWhenInsertingAtEnd() {
        let a = makeCourse(rating: .loved, rank: 1)
        let b = makeCourse(rating: .loved, rank: 2)

        let shifts = RankingEngine.shiftRanksForInsertion(
            insertAtRank: 3, allCourses: [a, b]
        )

        #expect(shifts.isEmpty)
    }

    @Test func allShiftWhenInsertingAtOne() {
        let a = makeCourse(rating: .loved, rank: 1)
        let b = makeCourse(rating: .liked, rank: 2)

        let shifts = RankingEngine.shiftRanksForInsertion(
            insertAtRank: 1, allCourses: [a, b]
        )

        #expect(shifts[a.id] == 2)
        #expect(shifts[b.id] == 3)
    }

    // MARK: - randomPlacement

    @Test func randomPlacementWithinBounds() {
        for _ in 0..<50 {
            let result = RankingEngine.randomPlacement(lowIndex: 2, highIndex: 5)
            #expect(result >= 2)
            #expect(result <= 5)
        }
    }

    @Test func randomPlacementSingleOption() {
        let result = RankingEngine.randomPlacement(lowIndex: 3, highIndex: 3)
        #expect(result == 3)
    }

    @Test func randomPlacementExhaustedRange() {
        let result = RankingEngine.randomPlacement(lowIndex: 5, highIndex: 3)
        #expect(result == 5)
    }

    // MARK: - Full binary search simulation

    @Test func binarySearchFindsCorrectPositionForBestInTier() {
        // Simulate: new course is better than all 3 existing courses
        let tier = [
            makeCourse(name: "A", rating: .liked, rank: 3),
            makeCourse(name: "B", rating: .liked, rank: 4),
            makeCourse(name: "C", rating: .liked, rank: 5),
        ]

        let low = 0
        var high = tier.count - 1
        var comparisons = 0

        while low <= high {
            guard let mid = RankingEngine.nextComparisonIndex(lowIndex: low, highIndex: high) else { break }
            comparisons += 1
            // Always prefer the new course (preferA) -> narrow to upper half
            high = mid - 1
        }

        let insertionIndex = low // should be 0 (best in tier)
        let globalRank = RankingEngine.globalRankForInsertion(insertionIndex: insertionIndex, tierCourses: tier)

        #expect(insertionIndex == 0)
        #expect(globalRank == 3)
        #expect(comparisons <= RankingEngine.expectedComparisons(tierSize: tier.count))
    }

    @Test func binarySearchFindsCorrectPositionForWorstInTier() {
        // Simulate: new course is worse than all 3 existing courses
        let tier = [
            makeCourse(name: "A", rating: .liked, rank: 3),
            makeCourse(name: "B", rating: .liked, rank: 4),
            makeCourse(name: "C", rating: .liked, rank: 5),
        ]

        var low = 0
        let high = tier.count - 1
        var comparisons = 0

        while low <= high {
            guard let mid = RankingEngine.nextComparisonIndex(lowIndex: low, highIndex: high) else { break }
            comparisons += 1
            // Always prefer existing (preferB) -> narrow to lower half
            low = mid + 1
        }

        let insertionIndex = low // should be 3 (worst in tier)
        let globalRank = RankingEngine.globalRankForInsertion(insertionIndex: insertionIndex, tierCourses: tier)

        #expect(insertionIndex == 3)
        #expect(globalRank == 6)
        #expect(comparisons <= RankingEngine.expectedComparisons(tierSize: tier.count))
    }
}
