//
//  ActivityItem.swift
//  Front Nine

import Foundation

enum ActivityType: String, Codable {
    case ranked
    case reRanked
}

struct ActivityItem: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let type: ActivityType
    let actorUid: String
    let actorDisplayName: String
    let actorHandle: String
    let courseName: String
    let courseCity: String
    let courseState: String
    let courseCountry: String?
    let courseRating: String // "Loved", "Liked", "Didn't Like"
    let newRankPosition: Int
    let oldRankPosition: Int? // only for reRanked
    let courseLatitude: Double?
    let courseLongitude: Double?
    let courseType: String?
    let courseHoleCount: Int?
    let tierRank: Int? // position within the tier (e.g., 2nd in Loved)
    let tierCount: Int? // total courses in that tier at time of ranking
    let timestamp: Date

    var courseLocationText: String {
        Course.formatLocation(city: courseCity, state: courseState, country: courseCountry)
    }

    /// Human-readable sentiment descriptor based on tier + relative position.
    var sentimentDescriptor: String {
        guard let rating = Rating(rawValue: courseRating) else { return "" }
        switch rating {
        case .loved:
            // "One of their all-time favorites" if top 10% of Loved AND at least 5 in tier
            if let rank = tierRank, let count = tierCount,
               count >= 5, Double(rank) / Double(count) <= 0.10 {
                return "One of their all-time favorites"
            }
            return "Loved it"
        case .liked:
            return "Liked it"
        case .disliked:
            return "Didn't like it"
        }
    }

    /// Builds a FirestoreRanking for navigation to SocialCourseDetailView.
    func toFirestoreRanking() -> FirestoreRanking {
        FirestoreRanking(
            id: id,
            name: courseName,
            city: courseCity,
            state: courseState,
            country: courseCountry,
            courseType: courseType ?? "Public",
            holeCount: courseHoleCount ?? 18,
            rating: courseRating,
            rankPosition: newRankPosition,
            notes: nil,
            par: nil,
            courseRating: nil,
            slope: nil,
            totalYards: nil,
            golfCourseApiId: nil,
            teeName: nil,
            latitude: courseLatitude,
            longitude: courseLongitude,
            createdAt: timestamp,
            updatedAt: timestamp
        )
    }

    func firestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "type": type.rawValue,
            "actorUid": actorUid,
            "actorDisplayName": actorDisplayName,
            "actorHandle": actorHandle,
            "courseName": courseName,
            "courseCity": courseCity,
            "courseState": courseState,
            "courseRating": courseRating,
            "newRankPosition": newRankPosition,
            "timestamp": timestamp
        ]

        if let courseCountry { data["courseCountry"] = courseCountry }
        if let oldRankPosition { data["oldRankPosition"] = oldRankPosition }
        if let courseLatitude { data["courseLatitude"] = courseLatitude }
        if let courseLongitude { data["courseLongitude"] = courseLongitude }
        if let courseType { data["courseType"] = courseType }
        if let courseHoleCount { data["courseHoleCount"] = courseHoleCount }
        if let tierRank { data["tierRank"] = tierRank }
        if let tierCount { data["tierCount"] = tierCount }

        return data
    }
}
