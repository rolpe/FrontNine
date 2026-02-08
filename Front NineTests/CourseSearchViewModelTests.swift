//
//  CourseSearchViewModelTests.swift
//  Front NineTests
//

import Foundation
import MapKit
import Testing
@testable import Front_Nine

struct CourseSearchViewModelTests {

    // Use an isolated UserDefaults suite per test to avoid cross-contamination
    private func makeVM() -> CourseSearchViewModel {
        let suiteName = "test-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)
        return CourseSearchViewModel(defaults: suite)
    }

    // MARK: - Recent Searches

    @Test func saveRecentSearchAddsToList() {
        let vm = makeVM()
        vm.saveRecentSearch("Pebble Beach")
        #expect(vm.recentSearches == ["Pebble Beach"])
    }

    @Test func recentSearchesMostRecentFirst() {
        let vm = makeVM()
        vm.saveRecentSearch("Augusta")
        vm.saveRecentSearch("Pebble Beach")
        vm.saveRecentSearch("St Andrews")
        #expect(vm.recentSearches == ["St Andrews", "Pebble Beach", "Augusta"])
    }

    @Test func recentSearchesLimitedToFour() {
        let vm = makeVM()
        vm.saveRecentSearch("One")
        vm.saveRecentSearch("Two")
        vm.saveRecentSearch("Three")
        vm.saveRecentSearch("Four")
        vm.saveRecentSearch("Five")
        #expect(vm.recentSearches.count == 4)
        #expect(vm.recentSearches.first == "Five")
        #expect(!vm.recentSearches.contains("One"))
    }

    @Test func recentSearchesDeduplicatesCaseInsensitive() {
        let vm = makeVM()
        vm.saveRecentSearch("Augusta")
        vm.saveRecentSearch("Pebble Beach")
        vm.saveRecentSearch("augusta")
        #expect(vm.recentSearches.count == 2)
        #expect(vm.recentSearches.first == "augusta")
    }

    @Test func emptyQueryNotSaved() {
        let vm = makeVM()
        vm.saveRecentSearch("")
        vm.saveRecentSearch("   ")
        #expect(vm.recentSearches.isEmpty)
    }

    @Test func recentSearchesPersistedToUserDefaults() {
        let suiteName = "test-\(UUID().uuidString)"
        let suite = UserDefaults(suiteName: suiteName)!
        suite.removePersistentDomain(forName: suiteName)

        let vm1 = CourseSearchViewModel(defaults: suite)
        vm1.saveRecentSearch("Pebble Beach")
        vm1.saveRecentSearch("Augusta")

        let vm2 = CourseSearchViewModel(defaults: suite)
        #expect(vm2.recentSearches == ["Augusta", "Pebble Beach"])
    }

    // MARK: - Already-Added Detection

    @Test func isAlreadyAddedMatchesByNameCityState() {
        let vm = makeVM()
        let course = Course(
            name: "Pebble Beach", city: "Pebble Beach", state: "CA",
            courseType: .public, holeCount: 18, rating: .loved, rankPosition: 1
        )
        vm.updateExistingCourses([course])

        let result = CourseSearchResult(
            id: "test|0|0", name: "Pebble Beach", city: "Pebble Beach", state: "CA",
            country: "United States", coordinate: .init(latitude: 0, longitude: 0)
        )
        #expect(vm.isAlreadyAdded(result))
    }

    @Test func isAlreadyAddedIsCaseInsensitive() {
        let vm = makeVM()
        let course = Course(
            name: "Pebble Beach", city: "Pebble Beach", state: "CA",
            courseType: .public, holeCount: 18, rating: .loved, rankPosition: 1
        )
        vm.updateExistingCourses([course])

        let result = CourseSearchResult(
            id: "test|0|0", name: "pebble beach", city: "pebble beach", state: "ca",
            country: "United States", coordinate: .init(latitude: 0, longitude: 0)
        )
        #expect(vm.isAlreadyAdded(result))
    }

    @Test func isAlreadyAddedReturnsFalseForDifferentCourse() {
        let vm = makeVM()
        let course = Course(
            name: "Augusta National", city: "Augusta", state: "GA",
            courseType: .private, holeCount: 18, rating: .loved, rankPosition: 1
        )
        vm.updateExistingCourses([course])

        let result = CourseSearchResult(
            id: "test|0|0", name: "Pebble Beach", city: "Pebble Beach", state: "CA",
            country: "United States", coordinate: .init(latitude: 0, longitude: 0)
        )
        #expect(!vm.isAlreadyAdded(result))
    }
}
