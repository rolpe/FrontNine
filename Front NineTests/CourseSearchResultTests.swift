//
//  CourseSearchResultTests.swift
//  Front NineTests
//

import MapKit
import Testing
@testable import Front_Nine

struct CourseSearchResultTests {

    // MARK: - USState.abbreviation(for:)

    @Test func abbreviationForExactMatch() {
        #expect(USState.abbreviation(for: "California") == "CA")
        #expect(USState.abbreviation(for: "New York") == "NY")
        #expect(USState.abbreviation(for: "Texas") == "TX")
    }

    @Test func abbreviationForCaseInsensitive() {
        #expect(USState.abbreviation(for: "california") == "CA")
        #expect(USState.abbreviation(for: "TEXAS") == "TX")
        #expect(USState.abbreviation(for: "new york") == "NY")
    }

    @Test func abbreviationForUnknownState() {
        #expect(USState.abbreviation(for: "Narnia") == nil)
        #expect(USState.abbreviation(for: "") == nil)
    }

    @Test func abbreviationForDistrictOfColumbia() {
        #expect(USState.abbreviation(for: "District of Columbia") == "DC")
    }

    // MARK: - CourseSearchResult Equatable

    @Test func equalityBasedOnId() {
        let a = CourseSearchResult(
            id: "Test|0.0|0.0", name: "Test", city: "City", state: "CA", country: "United States",
            coordinate: .init(latitude: 0, longitude: 0)
        )
        let b = CourseSearchResult(
            id: "Test|0.0|0.0", name: "Test", city: "City", state: "CA", country: "United States",
            coordinate: .init(latitude: 1, longitude: 1)
        )
        #expect(a == b)
    }

    @Test func inequalityWithDifferentId() {
        let a = CourseSearchResult(
            id: "A|0.0|0.0", name: "A", city: "City", state: "CA", country: "United States",
            coordinate: .init(latitude: 0, longitude: 0)
        )
        let b = CourseSearchResult(
            id: "B|0.0|0.0", name: "B", city: "City", state: "CA", country: "United States",
            coordinate: .init(latitude: 0, longitude: 0)
        )
        #expect(a != b)
    }
}
