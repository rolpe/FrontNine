//
//  ComparisonViewModelTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

struct ComparisonViewModelTests {

    // MARK: - Helpers

    private func makeCourse(
        name: String = "Test",
        rating: Rating = .liked,
        rank: Int = 1
    ) -> Course {
        Course(
            name: name, city: "City", state: "CA",
            courseType: .public, rating: rating, rankPosition: rank
        )
    }

    // MARK: - needsComparisons

    @Test func needsComparisonsWhenTierHasCourses() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)
        #expect(vm.needsComparisons)
    }

    @Test func noComparisonsWhenTierEmpty() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .loved, rank: 1),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)
        #expect(!vm.needsComparisons)
    }

    @Test func noComparisonsWhenNoExistingCourses() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: [])
        #expect(!vm.needsComparisons)
    }

    // MARK: - totalSteps

    @Test func totalStepsMatchesTierSize() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
            makeCourse(name: "C", rating: .liked, rank: 3),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)
        // 3 courses in tier -> ceil(log2(4)) = 2
        #expect(vm.totalSteps == 2)
    }

    // MARK: - choose preferA (new course is better)

    @Test func preferANarrowsHighBound() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
            makeCourse(name: "C", rating: .liked, rank: 3),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        // Initial: low=0, high=2, mid=1 (course B)
        #expect(vm.comparisonCourse?.name == "B")
        vm.choose(.preferA)
        // After preferA: high = mid-1 = 0, low still 0
        #expect(vm.currentStep == 1)
        #expect(vm.comparisonCourse?.name == "A")
    }

    // MARK: - choose preferB (existing course is better)

    @Test func preferBNarrowsLowBound() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
            makeCourse(name: "C", rating: .liked, rank: 3),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        // Initial: low=0, high=2, mid=1 (course B)
        vm.choose(.preferB)
        // After preferB: low = mid+1 = 2, high still 2
        #expect(vm.currentStep == 1)
        #expect(vm.comparisonCourse?.name == "C")
    }

    // MARK: - choose cantDecide

    @Test func cantDecideCompletesImmediately() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
            makeCourse(name: "C", rating: .liked, rank: 3),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        vm.choose(.cantDecide)
        #expect(vm.isComplete)
        #expect(vm.comparisonCourse == nil)
    }

    // MARK: - isComplete

    @Test func isCompleteAfterFullBinarySearch() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        #expect(!vm.isComplete)
        vm.choose(.preferA)
        #expect(vm.isComplete)
    }

    @Test func notCompleteInitially() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)
        #expect(!vm.isComplete)
    }

    // MARK: - finalRank

    @Test func finalRankWhenBetterThanAll() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        // mid=0 (A), prefer new -> high=-1, done, insert at index 0 -> rank 1
        vm.choose(.preferA)
        #expect(vm.finalRank == 1)
    }

    @Test func finalRankWhenWorseThanAll() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .liked, rank: 1),
            makeCourse(name: "B", rating: .liked, rank: 2),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)

        // mid=0 (A), prefer existing -> low=1
        vm.choose(.preferB)
        // mid=1 (B), prefer existing -> low=2, done
        vm.choose(.preferB)
        #expect(vm.finalRank == 3)
    }

    @Test func finalRankForEmptyTier() {
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let existing = [
            makeCourse(name: "A", rating: .loved, rank: 1),
            makeCourse(name: "B", rating: .loved, rank: 2),
        ]
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: existing)
        // Empty liked tier -> insert after loved courses
        #expect(vm.finalRank == 3)
    }

    // MARK: - rankShifts

    @Test func rankShiftsWhenInsertingAtTop() {
        let a = makeCourse(name: "A", rating: .liked, rank: 1)
        let b = makeCourse(name: "B", rating: .liked, rank: 2)
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: [a, b])

        // Better than mid=0 (A) -> insert at rank 1
        vm.choose(.preferA)
        let shifts = vm.rankShifts
        #expect(shifts[a.id] == 2)
        #expect(shifts[b.id] == 3)
    }

    @Test func rankShiftsEmptyWhenInsertingAtEnd() {
        let a = makeCourse(name: "A", rating: .liked, rank: 1)
        let b = makeCourse(name: "B", rating: .liked, rank: 2)
        let newCourse = makeCourse(name: "New", rating: .liked, rank: 0)
        let vm = ComparisonViewModel(newCourse: newCourse, existingCourses: [a, b])

        vm.choose(.preferB) // Worse than A -> low=1
        vm.choose(.preferB) // Worse than B -> low=2, done -> rank 3
        let shifts = vm.rankShifts
        #expect(shifts.isEmpty)
    }
}
