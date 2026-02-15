//
//  FirestoreRankingTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

struct FirestoreRankingTests {

    // MARK: - Helpers

    private func makeCourse(
        name: String = "Pebble Beach",
        city: String = "Pebble Beach",
        state: String = "CA",
        country: String? = "United States",
        courseType: CourseType = .public,
        holeCount: Int = 18,
        rating: Rating = .loved,
        rankPosition: Int = 1,
        notes: String? = "Beautiful course",
        par: Int? = 72,
        courseRating: Double? = 75.5,
        slope: Int? = 145,
        totalYards: Int? = 6828,
        golfCourseApiId: Int? = 12345,
        teeName: String? = "White Tees",
        latitude: Double? = 36.5725,
        longitude: Double? = -121.9486
    ) -> Course {
        Course(
            name: name, city: city, state: state,
            courseType: courseType, holeCount: holeCount,
            notes: notes, rating: rating, rankPosition: rankPosition,
            country: country, par: par, courseRating: courseRating,
            slope: slope, totalYards: totalYards,
            golfCourseApiId: golfCourseApiId, teeName: teeName,
            latitude: latitude, longitude: longitude
        )
    }

    // MARK: - init(from:)

    @Test func initFromCourseMapsAllFields() {
        let course = makeCourse()
        let ranking = FirestoreRanking(from: course)

        #expect(ranking.id == course.id.uuidString)
        #expect(ranking.name == "Pebble Beach")
        #expect(ranking.city == "Pebble Beach")
        #expect(ranking.state == "CA")
        #expect(ranking.country == "United States")
        #expect(ranking.courseType == "Public")
        #expect(ranking.holeCount == 18)
        #expect(ranking.rating == "Loved")
        #expect(ranking.rankPosition == 1)
        #expect(ranking.notes == "Beautiful course")
        #expect(ranking.par == 72)
        #expect(ranking.courseRating == 75.5)
        #expect(ranking.slope == 145)
        #expect(ranking.totalYards == 6828)
        #expect(ranking.golfCourseApiId == 12345)
        #expect(ranking.teeName == "White Tees")
        #expect(ranking.latitude == 36.5725)
        #expect(ranking.longitude == -121.9486)
        #expect(ranking.createdAt == course.createdAt)
        #expect(ranking.updatedAt == course.updatedAt)
    }

    @Test func initFromCourseHandlesNilOptionals() {
        let course = makeCourse(
            country: nil, notes: nil,
            par: nil, courseRating: nil, slope: nil,
            totalYards: nil, golfCourseApiId: nil, teeName: nil,
            latitude: nil, longitude: nil
        )
        let ranking = FirestoreRanking(from: course)

        #expect(ranking.country == nil)
        #expect(ranking.notes == nil)
        #expect(ranking.par == nil)
        #expect(ranking.courseRating == nil)
        #expect(ranking.slope == nil)
        #expect(ranking.totalYards == nil)
        #expect(ranking.golfCourseApiId == nil)
        #expect(ranking.teeName == nil)
        #expect(ranking.latitude == nil)
        #expect(ranking.longitude == nil)
    }

    @Test func initFromCourseMapsCourseTypePrivate() {
        let course = makeCourse(courseType: .private)
        let ranking = FirestoreRanking(from: course)
        #expect(ranking.courseType == "Private")
    }

    @Test func initFromCourseMapsCourseTypePublic() {
        let course = makeCourse(courseType: .public)
        let ranking = FirestoreRanking(from: course)
        #expect(ranking.courseType == "Public")
    }

    @Test func initFromCourseMapsAllRatingValues() {
        let loved = FirestoreRanking(from: makeCourse(rating: .loved))
        let liked = FirestoreRanking(from: makeCourse(rating: .liked))
        let disliked = FirestoreRanking(from: makeCourse(rating: .disliked))

        #expect(loved.rating == "Loved")
        #expect(liked.rating == "Liked")
        #expect(disliked.rating == "Didn't Love")
    }

    @Test func initFromCourseHandlesEmptyState() {
        let course = makeCourse(state: "")
        let ranking = FirestoreRanking(from: course)
        #expect(ranking.state == "")
    }

    // MARK: - firestoreData

    @Test func firestoreDataContainsRequiredKeys() {
        let course = makeCourse()
        let data = FirestoreRanking(from: course).firestoreData()

        #expect(data["id"] as? String == course.id.uuidString)
        #expect(data["name"] as? String == "Pebble Beach")
        #expect(data["city"] as? String == "Pebble Beach")
        #expect(data["state"] as? String == "CA")
        #expect(data["courseType"] as? String == "Public")
        #expect(data["holeCount"] as? Int == 18)
        #expect(data["rating"] as? String == "Loved")
        #expect(data["rankPosition"] as? Int == 1)
        #expect(data["createdAt"] != nil)
        #expect(data["updatedAt"] != nil)
    }

    @Test func firestoreDataIncludesOptionalFieldsWhenPresent() {
        let course = makeCourse()
        let data = FirestoreRanking(from: course).firestoreData()

        #expect(data["country"] as? String == "United States")
        #expect(data["notes"] as? String == "Beautiful course")
        #expect(data["par"] as? Int == 72)
        #expect(data["courseRating"] as? Double == 75.5)
        #expect(data["slope"] as? Int == 145)
        #expect(data["totalYards"] as? Int == 6828)
        #expect(data["golfCourseApiId"] as? Int == 12345)
        #expect(data["teeName"] as? String == "White Tees")
        #expect(data["latitude"] as? Double == 36.5725)
        #expect(data["longitude"] as? Double == -121.9486)
    }

    @Test func firestoreDataExcludesNilOptionals() {
        let course = makeCourse(
            country: nil, notes: nil,
            par: nil, courseRating: nil, slope: nil,
            totalYards: nil, golfCourseApiId: nil, teeName: nil,
            latitude: nil, longitude: nil
        )
        let data = FirestoreRanking(from: course).firestoreData()

        // Required keys: 10 (id, name, city, state, courseType, holeCount, rating, rankPosition, createdAt, updatedAt)
        #expect(data.count == 10)
        #expect(data["country"] == nil)
        #expect(data["notes"] == nil)
        #expect(data["par"] == nil)
    }

    @Test func firestoreDataFullCourseHasAllKeys() {
        let course = makeCourse()
        let data = FirestoreRanking(from: course).firestoreData()

        // 10 required + 10 optional = 20
        #expect(data.count == 20)
    }

    // MARK: - Equatable

    @Test func equalRankingsFromSameCourse() {
        let course = makeCourse()
        let a = FirestoreRanking(from: course)
        let b = FirestoreRanking(from: course)
        #expect(a == b)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        let course = makeCourse()
        let original = FirestoreRanking(from: course)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FirestoreRanking.self, from: data)

        #expect(decoded.id == original.id)
        #expect(decoded.name == original.name)
        #expect(decoded.rating == original.rating)
        #expect(decoded.rankPosition == original.rankPosition)
        #expect(decoded.par == original.par)
        #expect(decoded.country == original.country)
    }

    @Test func codableRoundTripWithNils() throws {
        let course = makeCourse(
            country: nil, notes: nil, par: nil, courseRating: nil,
            slope: nil, totalYards: nil, golfCourseApiId: nil,
            teeName: nil, latitude: nil, longitude: nil
        )
        let original = FirestoreRanking(from: course)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FirestoreRanking.self, from: data)

        #expect(decoded.country == nil)
        #expect(decoded.notes == nil)
        #expect(decoded.par == nil)
        #expect(decoded.latitude == nil)
    }
}
