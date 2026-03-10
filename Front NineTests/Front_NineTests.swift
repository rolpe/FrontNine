//
//  Front_NineTests.swift
//  Front NineTests
//
//  Created by Ron Lipkin on 2/1/26.
//

import Testing
import SwiftData
import Foundation
@testable import Front_Nine

struct CourseModelTests {

    @Test func courseInitializesWithDefaults() {
        let course = Course(
            name: "Pebble Beach Golf Links",
            city: "Pebble Beach",
            state: "CA",
            courseType: .public,
            rating: .loved
        )

        #expect(course.name == "Pebble Beach Golf Links")
        #expect(course.city == "Pebble Beach")
        #expect(course.state == "CA")
        #expect(course.courseType == .public)
        #expect(course.holeCount == 18)
        #expect(course.notes == nil)
        #expect(course.rating == .loved)
        #expect(course.rankPosition == 0)
    }

    @Test func courseInitializesWithAllParameters() {
        let course = Course(
            name: "Augusta National",
            city: "Augusta",
            state: "GA",
            courseType: .private,
            holeCount: 18,
            notes: "Home of the Masters",
            rating: .loved,
            rankPosition: 1
        )

        #expect(course.name == "Augusta National")
        #expect(course.courseType == .private)
        #expect(course.holeCount == 18)
        #expect(course.notes == "Home of the Masters")
        #expect(course.rankPosition == 1)
    }

    @Test func courseTypeRawValues() {
        #expect(CourseType.public.rawValue == "Public")
        #expect(CourseType.private.rawValue == "Private")
    }

    @Test func ratingTierOrder() {
        #expect(Rating.loved.tierOrder < Rating.liked.tierOrder)
        #expect(Rating.liked.tierOrder < Rating.disliked.tierOrder)
    }

    @Test func ratingEmoji() {
        #expect(Rating.loved.emoji == "\u{1F60D}")
        #expect(Rating.liked.emoji == "\u{1F44D}")
        #expect(Rating.disliked.emoji == "\u{1F44E}")
    }

    @Test func ratingLabel() {
        #expect(Rating.loved.label == "Loved")
        #expect(Rating.liked.label == "Liked")
        #expect(Rating.disliked.label == "Didn't Like")
    }

    @Test func ratingDecodesCurrentValue() throws {
        let json = Data(#""Didn't Like""#.utf8)
        let rating = try JSONDecoder().decode(Rating.self, from: json)
        #expect(rating == .disliked)
    }

    @Test func ratingDecodesLegacyValue() throws {
        let json = Data(#""Didn't Love""#.utf8)
        let rating = try JSONDecoder().decode(Rating.self, from: json)
        #expect(rating == .disliked)
    }

    @Test func ratingEncodesToNewValue() throws {
        let data = try JSONEncoder().encode(Rating.disliked)
        let string = String(data: data, encoding: .utf8)
        #expect(string == #""Didn't Like""#)
    }

    @Test func ratingCaseIterableOrder() {
        let allCases = Rating.allCases
        #expect(allCases[0] == .loved)
        #expect(allCases[1] == .liked)
        #expect(allCases[2] == .disliked)
    }

    @Test func usStateCount() {
        #expect(USState.allCases.count == 51) // 50 states + DC
    }

    @Test func courseSwiftDataRoundTrip() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Course.self, configurations: config)
        let context = ModelContext(container)

        let course = Course(
            name: "Bethpage Black",
            city: "Farmingdale",
            state: "NY",
            courseType: .public,
            holeCount: 18,
            notes: "Tough but fair",
            rating: .liked,
            rankPosition: 4
        )

        context.insert(course)
        try context.save()

        let descriptor = FetchDescriptor<Course>()
        let fetched = try context.fetch(descriptor)

        #expect(fetched.count == 1)
        #expect(fetched[0].name == "Bethpage Black")
        #expect(fetched[0].city == "Farmingdale")
        #expect(fetched[0].state == "NY")
        #expect(fetched[0].courseType == .public)
        #expect(fetched[0].holeCount == 18)
        #expect(fetched[0].notes == "Tough but fair")
        #expect(fetched[0].rating == .liked)
        #expect(fetched[0].rankPosition == 4)
    }
}
