//
//  RankingEngine.swift
//  Front Nine
//

import Foundation

/// Lightweight value type for comparison logic, decoupled from SwiftData.
struct RankedCourse: Identifiable {
    let id: UUID
    let name: String
    let city: String
    let state: String
    let rating: Rating
    let rankPosition: Int
}

/// Outcome of a single head-to-head comparison.
enum ComparisonChoice {
    case preferA    // User prefers the new course
    case preferB    // User prefers the existing course
    case cantDecide // Random placement in remaining range
}

/// Result of the full comparison flow.
struct RankingResult {
    let insertAtRank: Int
}

/// Pure-logic ranking engine. No SwiftData or SwiftUI dependency.
/// Uses binary search within a tier to find the correct insertion point.
struct RankingEngine {

    /// Returns courses in the given tier, sorted by rank position.
    static func coursesInTier(
        rating: Rating,
        allCourses: [RankedCourse]
    ) -> [RankedCourse] {
        allCourses
            .filter { $0.rating == rating }
            .sorted { $0.rankPosition < $1.rankPosition }
    }

    /// Calculates expected number of comparisons for a binary search.
    static func expectedComparisons(tierSize: Int) -> Int {
        if tierSize <= 0 { return 0 }
        if tierSize == 1 { return 1 }
        return Int(ceil(log2(Double(tierSize + 1))))
    }

    /// Returns the index of the next course to compare against,
    /// or nil if the search is exhausted.
    static func nextComparisonIndex(
        lowIndex: Int,
        highIndex: Int
    ) -> Int? {
        guard lowIndex <= highIndex else { return nil }
        return (lowIndex + highIndex) / 2
    }

    /// Determines where a tier's courses should begin in the global ranking
    /// when the tier is empty.
    static func emptyTierInsertionRank(
        for rating: Rating,
        allCourses: [RankedCourse]
    ) -> Int {
        let aboveCount: Int
        switch rating {
        case .loved:
            aboveCount = 0
        case .liked:
            aboveCount = allCourses.filter { $0.rating == .loved }.count
        case .disliked:
            aboveCount = allCourses.filter { $0.rating == .loved || $0.rating == .liked }.count
        }
        return aboveCount + 1
    }

    /// Converts a tier-local insertion index into a global rank position.
    ///
    /// - Parameters:
    ///   - insertionIndex: Where the course lands in the tier array (0 = best in tier).
    ///   - tierCourses: Existing courses in the tier, sorted by rank.
    /// - Returns: The global rank position for the new course.
    static func globalRankForInsertion(
        insertionIndex: Int,
        tierCourses: [RankedCourse]
    ) -> Int {
        if tierCourses.isEmpty {
            return 1
        }
        if insertionIndex <= 0 {
            return tierCourses[0].rankPosition
        }
        if insertionIndex >= tierCourses.count {
            return tierCourses[tierCourses.count - 1].rankPosition + 1
        }
        return tierCourses[insertionIndex].rankPosition
    }

    /// Returns a dictionary of [courseID: newRankPosition] for all courses
    /// that need to shift down to make room for an insertion.
    static func shiftRanksForInsertion(
        insertAtRank: Int,
        allCourses: [RankedCourse]
    ) -> [UUID: Int] {
        var updates: [UUID: Int] = [:]
        for course in allCourses {
            if course.rankPosition >= insertAtRank {
                updates[course.id] = course.rankPosition + 1
            }
        }
        return updates
    }

    /// Random placement within the remaining binary search range.
    static func randomPlacement(lowIndex: Int, highIndex: Int) -> Int {
        guard lowIndex <= highIndex else { return lowIndex }
        return Int.random(in: lowIndex...highIndex)
    }

    /// Recomputes contiguous 1..N rank positions respecting tier order.
    /// Call this as a safety net if gaps or duplicates are suspected.
    static func normalizeRanks(_ courses: [RankedCourse]) -> [UUID: Int] {
        let sorted = courses.sorted {
            if $0.rating.tierOrder != $1.rating.tierOrder {
                return $0.rating.tierOrder < $1.rating.tierOrder
            }
            return $0.rankPosition < $1.rankPosition
        }
        var updates: [UUID: Int] = [:]
        for (index, course) in sorted.enumerated() {
            let correctRank = index + 1
            if course.rankPosition != correctRank {
                updates[course.id] = correctRank
            }
        }
        return updates
    }
}
