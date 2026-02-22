//
//  UserProfileTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

struct UserProfileTests {

    // MARK: - Initialization

    @Test func initSetsAllProperties() {
        let date = Date()
        let profile = UserProfile(
            uid: "abc123",
            displayName: "Ron",
            handle: "ronlipkin",
            createdAt: date,
            updatedAt: date
        )

        #expect(profile.uid == "abc123")
        #expect(profile.displayName == "Ron")
        #expect(profile.handle == "ronlipkin")
        #expect(profile.isPublic == true)
        #expect(profile.followerCount == 0)
        #expect(profile.followingCount == 0)
        #expect(profile.rankingCount == 0)
        #expect(profile.createdAt == date)
        #expect(profile.updatedAt == date)
    }

    @Test func initWithCustomSocialFields() {
        let date = Date()
        let profile = UserProfile(
            uid: "abc123",
            displayName: "Ron",
            handle: "ronlipkin",
            isPublic: false,
            followerCount: 10,
            followingCount: 5,
            rankingCount: 42,
            createdAt: date,
            updatedAt: date
        )

        #expect(profile.isPublic == false)
        #expect(profile.followerCount == 10)
        #expect(profile.followingCount == 5)
        #expect(profile.rankingCount == 42)
    }

    // MARK: - Equatable

    @Test func equalProfilesAreEqual() {
        let date = Date()
        let a = UserProfile(uid: "1", displayName: "A", handle: "a", createdAt: date, updatedAt: date)
        let b = UserProfile(uid: "1", displayName: "A", handle: "a", createdAt: date, updatedAt: date)
        #expect(a == b)
    }

    @Test func differentHandlesAreNotEqual() {
        let date = Date()
        let a = UserProfile(uid: "1", displayName: "A", handle: "a", createdAt: date, updatedAt: date)
        let b = UserProfile(uid: "1", displayName: "A", handle: "b", createdAt: date, updatedAt: date)
        #expect(a != b)
    }

    @Test func differentUIDsAreNotEqual() {
        let date = Date()
        let a = UserProfile(uid: "1", displayName: "A", handle: "a", createdAt: date, updatedAt: date)
        let b = UserProfile(uid: "2", displayName: "A", handle: "a", createdAt: date, updatedAt: date)
        #expect(a != b)
    }

    // MARK: - Codable

    @Test func codableRoundTrip() throws {
        // Use whole-second date to avoid ISO 8601 fractional second precision loss
        let date = Date(timeIntervalSince1970: 1700000000)
        let original = UserProfile(
            uid: "test-uid",
            displayName: "Test User",
            handle: "testuser",
            createdAt: date,
            updatedAt: date
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserProfile.self, from: data)

        #expect(decoded == original)
    }

    @Test func decodesFromJSON() throws {
        let json = """
        {
            "uid": "uid-1",
            "displayName": "John",
            "handle": "john_doe",
            "isPublic": true,
            "followerCount": 5,
            "followingCount": 3,
            "rankingCount": 12,
            "createdAt": "2024-01-15T12:00:00Z",
            "updatedAt": "2024-06-20T15:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let profile = try decoder.decode(UserProfile.self, from: Data(json.utf8))

        #expect(profile.uid == "uid-1")
        #expect(profile.displayName == "John")
        #expect(profile.handle == "john_doe")
        #expect(profile.isPublic == true)
        #expect(profile.followerCount == 5)
        #expect(profile.followingCount == 3)
        #expect(profile.rankingCount == 12)
    }

    @Test func mutatingPropertiesWork() {
        let date = Date()
        var profile = UserProfile(
            uid: "1", displayName: "Old", handle: "old",
            createdAt: date, updatedAt: date
        )

        profile.displayName = "New"
        profile.handle = "new_handle"

        #expect(profile.displayName == "New")
        #expect(profile.handle == "new_handle")
        #expect(profile.uid == "1") // uid is let, unchanged
    }

    // MARK: - firestoreData

    @Test func firestoreDataContainsAllKeys() {
        let date = Date()
        let profile = UserProfile(
            uid: "uid-1",
            displayName: "Test User",
            handle: "testuser",
            createdAt: date,
            updatedAt: date
        )

        let data = profile.firestoreData()

        #expect(data["uid"] as? String == "uid-1")
        #expect(data["displayName"] as? String == "Test User")
        #expect(data["displayNameLower"] as? String == "test user")
        #expect(data["handle"] as? String == "testuser")
        #expect(data["isPublic"] as? Bool == true)
        #expect(data["followerCount"] as? Int == 0)
        #expect(data["followingCount"] as? Int == 0)
        #expect(data["rankingCount"] as? Int == 0)
        #expect(data["createdAt"] as? Date == date)
        #expect(data["updatedAt"] as? Date == date)
        #expect(data.count == 10)
    }

    @Test func firestoreDataPreservesSpecialCharacters() {
        let date = Date()
        let profile = UserProfile(
            uid: "uid-1",
            displayName: "José García",
            handle: "jose_garcia",
            createdAt: date,
            updatedAt: date
        )

        let data = profile.firestoreData()
        #expect(data["displayName"] as? String == "José García")
    }
}
