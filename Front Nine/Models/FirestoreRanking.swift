//
//  FirestoreRanking.swift
//  Front Nine
//

import Foundation

/// Value type that maps a Course's fields to a Firestore document.
/// Keeps Firestore serialization separate from the SwiftData @Model.
struct FirestoreRanking: Codable, Equatable, Hashable {
    let id: String // UUID string
    var name: String
    var city: String
    var state: String
    var country: String?
    var courseType: String // "Public" or "Private"
    var holeCount: Int
    var rating: String // "Loved", "Liked", "Didn't Love"
    var rankPosition: Int
    var notes: String?
    var par: Int?
    var courseRating: Double?
    var slope: Int?
    var totalYards: Int?
    var golfCourseApiId: Int?
    var teeName: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String, name: String, city: String, state: String, country: String?,
        courseType: String, holeCount: Int, rating: String, rankPosition: Int,
        notes: String?, par: Int?, courseRating: Double?, slope: Int?,
        totalYards: Int?, golfCourseApiId: Int?, teeName: String?,
        latitude: Double?, longitude: Double?, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.country = country
        self.courseType = courseType
        self.holeCount = holeCount
        self.rating = rating
        self.rankPosition = rankPosition
        self.notes = notes
        self.par = par
        self.courseRating = courseRating
        self.slope = slope
        self.totalYards = totalYards
        self.golfCourseApiId = golfCourseApiId
        self.teeName = teeName
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from course: Course) {
        self.id = course.id.uuidString
        self.name = course.name
        self.city = course.city
        self.state = course.state
        self.country = course.country
        self.courseType = course.courseType.rawValue
        self.holeCount = course.holeCount
        self.rating = course.rating.rawValue
        self.rankPosition = course.rankPosition
        self.notes = course.notes
        self.par = course.par
        self.courseRating = course.courseRating
        self.slope = course.slope
        self.totalYards = course.totalYards
        self.golfCourseApiId = course.golfCourseApiId
        self.teeName = course.teeName
        self.latitude = course.latitude
        self.longitude = course.longitude
        self.createdAt = course.createdAt
        self.updatedAt = course.updatedAt
    }

    func firestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "id": id,
            "name": name,
            "city": city,
            "state": state,
            "courseType": courseType,
            "holeCount": holeCount,
            "rating": rating,
            "rankPosition": rankPosition,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]

        // Optional fields — only include if non-nil
        if let country { data["country"] = country }
        if let notes { data["notes"] = notes }
        if let par { data["par"] = par }
        if let courseRating { data["courseRating"] = courseRating }
        if let slope { data["slope"] = slope }
        if let totalYards { data["totalYards"] = totalYards }
        if let golfCourseApiId { data["golfCourseApiId"] = golfCourseApiId }
        if let teeName { data["teeName"] = teeName }
        if let latitude { data["latitude"] = latitude }
        if let longitude { data["longitude"] = longitude }

        return data
    }
}
