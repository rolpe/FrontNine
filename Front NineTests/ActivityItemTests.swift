//
//  ActivityItemTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

@MainActor
struct ActivityItemTests {

    // MARK: - Helpers

    private func makeRankedItem(
        id: String = "item1",
        actorUid: String = "user1",
        actorDisplayName: String = "Tiger Woods",
        actorHandle: String = "tiger",
        courseName: String = "Augusta National Golf Club",
        courseCity: String = "Augusta",
        courseState: String = "GA",
        courseCountry: String? = "United States",
        courseRating: String = "Loved",
        newRankPosition: Int = 1,
        courseLatitude: Double? = 33.5033,
        courseLongitude: Double? = -82.0231,
        courseType: String? = "Private",
        courseHoleCount: Int? = 18,
        timestamp: Date = Date()
    ) -> ActivityItem {
        ActivityItem(
            id: id,
            type: .ranked,
            actorUid: actorUid,
            actorDisplayName: actorDisplayName,
            actorHandle: actorHandle,
            courseName: courseName,
            courseCity: courseCity,
            courseState: courseState,
            courseCountry: courseCountry,
            courseRating: courseRating,
            newRankPosition: newRankPosition,
            oldRankPosition: nil,
            courseLatitude: courseLatitude,
            courseLongitude: courseLongitude,
            courseType: courseType,
            courseHoleCount: courseHoleCount,
            tierRank: nil,
            tierCount: nil,
            timestamp: timestamp
        )
    }

    private func makeReRankedItem(
        id: String = "item2",
        oldRankPosition: Int = 5,
        newRankPosition: Int = 2
    ) -> ActivityItem {
        ActivityItem(
            id: id,
            type: .reRanked,
            actorUid: "user1",
            actorDisplayName: "Tiger Woods",
            actorHandle: "tiger",
            courseName: "St Andrews Old Course",
            courseCity: "St Andrews",
            courseState: "",
            courseCountry: "Scotland",
            courseRating: "Liked",
            newRankPosition: newRankPosition,
            oldRankPosition: oldRankPosition,
            courseLatitude: 56.3433,
            courseLongitude: -2.8027,
            courseType: "Public",
            courseHoleCount: 18,
            tierRank: nil,
            tierCount: nil,
            timestamp: Date()
        )
    }

    // MARK: - Init

    @Test func initSetsAllProperties() {
        let timestamp = Date()
        let item = ActivityItem(
            id: "abc",
            type: .ranked,
            actorUid: "uid1",
            actorDisplayName: "Test User",
            actorHandle: "testuser",
            courseName: "Pebble Beach",
            courseCity: "Pebble Beach",
            courseState: "CA",
            courseCountry: "United States",
            courseRating: "Loved",
            newRankPosition: 3,
            oldRankPosition: nil,
            courseLatitude: 36.5682,
            courseLongitude: -121.9487,
            courseType: "Public",
            courseHoleCount: 18,
            tierRank: nil,
            tierCount: nil,
            timestamp: timestamp
        )

        #expect(item.id == "abc")
        #expect(item.type == .ranked)
        #expect(item.actorUid == "uid1")
        #expect(item.actorDisplayName == "Test User")
        #expect(item.actorHandle == "testuser")
        #expect(item.courseName == "Pebble Beach")
        #expect(item.courseCity == "Pebble Beach")
        #expect(item.courseState == "CA")
        #expect(item.courseCountry == "United States")
        #expect(item.courseRating == "Loved")
        #expect(item.newRankPosition == 3)
        #expect(item.oldRankPosition == nil)
        #expect(item.courseLatitude == 36.5682)
        #expect(item.courseLongitude == -121.9487)
        #expect(item.courseType == "Public")
        #expect(item.courseHoleCount == 18)
        #expect(item.timestamp == timestamp)
    }

    @Test func reRankedItemHasOldRankPosition() {
        let item = makeReRankedItem(oldRankPosition: 7, newRankPosition: 3)
        #expect(item.type == .reRanked)
        #expect(item.oldRankPosition == 7)
        #expect(item.newRankPosition == 3)
    }

    // MARK: - Codable Round-Trip

    @Test func codableRoundTripRankedItem() throws {
        let original = makeRankedItem()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ActivityItem.self, from: data)
        #expect(original == decoded)
    }

    @Test func codableRoundTripReRankedItem() throws {
        let original = makeReRankedItem()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ActivityItem.self, from: data)
        #expect(original == decoded)
    }

    @Test func codableRoundTripWithNilOptionals() throws {
        let original = makeRankedItem(
            courseCountry: nil,
            courseLatitude: nil,
            courseLongitude: nil,
            courseType: nil,
            courseHoleCount: nil
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ActivityItem.self, from: data)
        #expect(original == decoded)
        #expect(decoded.courseCountry == nil)
        #expect(decoded.courseLatitude == nil)
        #expect(decoded.courseLongitude == nil)
        #expect(decoded.courseType == nil)
        #expect(decoded.courseHoleCount == nil)
    }

    // MARK: - ActivityType Codable

    @Test func activityTypeCodableRanked() throws {
        let data = try JSONEncoder().encode(ActivityType.ranked)
        let decoded = try JSONDecoder().decode(ActivityType.self, from: data)
        #expect(decoded == .ranked)
    }

    @Test func activityTypeCodableReRanked() throws {
        let data = try JSONEncoder().encode(ActivityType.reRanked)
        let decoded = try JSONDecoder().decode(ActivityType.self, from: data)
        #expect(decoded == .reRanked)
    }

    // MARK: - firestoreData

    @Test func firestoreDataContainsRequiredKeys() {
        let item = makeRankedItem()
        let data = item.firestoreData()

        #expect(data["type"] as? String == "ranked")
        #expect(data["actorUid"] as? String == "user1")
        #expect(data["actorDisplayName"] as? String == "Tiger Woods")
        #expect(data["actorHandle"] as? String == "tiger")
        #expect(data["courseName"] as? String == "Augusta National Golf Club")
        #expect(data["courseCity"] as? String == "Augusta")
        #expect(data["courseState"] as? String == "GA")
        #expect(data["courseRating"] as? String == "Loved")
        #expect(data["newRankPosition"] as? Int == 1)
        #expect(data["timestamp"] != nil)
    }

    @Test func firestoreDataIncludesNonNilOptionals() {
        let item = makeRankedItem()
        let data = item.firestoreData()

        #expect(data["courseCountry"] as? String == "United States")
        #expect(data["courseLatitude"] as? Double == 33.5033)
        #expect(data["courseLongitude"] as? Double == -82.0231)
        #expect(data["courseType"] as? String == "Private")
        #expect(data["courseHoleCount"] as? Int == 18)
    }

    @Test func firestoreDataOmitsNilOptionals() {
        let item = makeRankedItem(
            courseCountry: nil,
            courseLatitude: nil,
            courseLongitude: nil,
            courseType: nil,
            courseHoleCount: nil
        )
        let data = item.firestoreData()

        #expect(data["courseCountry"] == nil)
        #expect(data["oldRankPosition"] == nil)
        #expect(data["courseLatitude"] == nil)
        #expect(data["courseLongitude"] == nil)
        #expect(data["courseType"] == nil)
        #expect(data["courseHoleCount"] == nil)
    }

    @Test func firestoreDataIncludesOldRankForReRanked() {
        let item = makeReRankedItem(oldRankPosition: 5, newRankPosition: 2)
        let data = item.firestoreData()

        #expect(data["type"] as? String == "reRanked")
        #expect(data["oldRankPosition"] as? Int == 5)
        #expect(data["newRankPosition"] as? Int == 2)
    }

    @Test func firestoreDataExcludesId() {
        let item = makeRankedItem()
        let data = item.firestoreData()
        #expect(data["id"] == nil)
    }

    // MARK: - Equatable

    @Test func equalItemsAreEqual() {
        let timestamp = Date()
        let item1 = makeRankedItem(id: "same", timestamp: timestamp)
        let item2 = makeRankedItem(id: "same", timestamp: timestamp)
        #expect(item1 == item2)
    }

    @Test func differentIdsAreNotEqual() {
        let timestamp = Date()
        let item1 = makeRankedItem(id: "a", timestamp: timestamp)
        let item2 = makeRankedItem(id: "b", timestamp: timestamp)
        #expect(item1 != item2)
    }

    // MARK: - Hashable

    @Test func equalItemsHaveSameHash() {
        let timestamp = Date()
        let item1 = makeRankedItem(id: "same", timestamp: timestamp)
        let item2 = makeRankedItem(id: "same", timestamp: timestamp)
        #expect(item1.hashValue == item2.hashValue)
    }

    @Test func canBeUsedAsSetElement() {
        let timestamp = Date()
        let item1 = makeRankedItem(id: "a", timestamp: timestamp)
        let item2 = makeRankedItem(id: "b", timestamp: timestamp)
        let set: Set<ActivityItem> = [item1, item2]
        #expect(set.count == 2)
    }

    // MARK: - courseLocationText

    @Test func courseLocationTextForUSCourse() {
        let item = makeRankedItem(courseCity: "Augusta", courseState: "GA", courseCountry: "United States")
        // formatLocation handles locale-aware country display
        let text = item.courseLocationText
        #expect(text.contains("Augusta"))
        #expect(text.contains("GA"))
    }

    @Test func courseLocationTextForInternationalCourse() {
        let item = makeReRankedItem()
        let text = item.courseLocationText
        #expect(text.contains("St Andrews"))
    }

    // MARK: - toFirestoreRanking

    @Test func toFirestoreRankingMapsFieldsCorrectly() {
        let item = makeRankedItem()
        let ranking = item.toFirestoreRanking()

        #expect(ranking.id == item.id)
        #expect(ranking.name == item.courseName)
        #expect(ranking.city == item.courseCity)
        #expect(ranking.state == item.courseState)
        #expect(ranking.country == item.courseCountry)
        #expect(ranking.courseType == "Private")
        #expect(ranking.holeCount == 18)
        #expect(ranking.rating == item.courseRating)
        #expect(ranking.rankPosition == item.newRankPosition)
        #expect(ranking.latitude == item.courseLatitude)
        #expect(ranking.longitude == item.courseLongitude)
        #expect(ranking.createdAt == item.timestamp)
        #expect(ranking.updatedAt == item.timestamp)
    }

    @Test func toFirestoreRankingDefaultsNilCourseType() {
        let item = makeRankedItem(courseType: nil)
        let ranking = item.toFirestoreRanking()
        #expect(ranking.courseType == "Public")
    }

    @Test func toFirestoreRankingDefaultsNilHoleCount() {
        let item = makeRankedItem(courseHoleCount: nil)
        let ranking = item.toFirestoreRanking()
        #expect(ranking.holeCount == 18)
    }

    @Test func toFirestoreRankingNilsEnrichmentFields() {
        let item = makeRankedItem()
        let ranking = item.toFirestoreRanking()
        #expect(ranking.notes == nil)
        #expect(ranking.par == nil)
        #expect(ranking.courseRating == nil)
        #expect(ranking.slope == nil)
        #expect(ranking.totalYards == nil)
        #expect(ranking.golfCourseApiId == nil)
        #expect(ranking.teeName == nil)
    }
}
