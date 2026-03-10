//
//  Course.swift
//  Front Nine
//

import Foundation
import SwiftData

enum CourseType: String, Codable, CaseIterable {
    case `public` = "Public"
    case `private` = "Private"
    case other = "Other"
}

enum Rating: String, Codable, CaseIterable {
    case loved = "Loved"
    case liked = "Liked"
    case disliked = "Didn't Like"

    /// Decode legacy "Didn't Love" values from SwiftData and Firestore
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        if value == "Didn't Love" {
            self = .disliked
        } else if let rating = Rating(rawValue: value) {
            self = rating
        } else {
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Unknown rating: \(value)"
            )
        }
    }

    var tierOrder: Int {
        switch self {
        case .loved: return 0
        case .liked: return 1
        case .disliked: return 2
        }
    }

    var emoji: String {
        switch self {
        case .loved: return "\u{1F60D}"
        case .liked: return "\u{1F44D}"
        case .disliked: return "\u{1F44E}"
        }
    }

    var label: String { rawValue }
}

@Model
final class Course {
    var id: UUID
    var name: String
    var city: String
    var state: String
    var courseType: CourseType
    var holeCount: Int
    var notes: String?
    var rating: Rating
    var rankPosition: Int
    var createdAt: Date
    var updatedAt: Date
    var country: String?
    var par: Int?
    var courseRating: Double?
    var slope: Int?
    var totalYards: Int?
    var golfCourseApiId: Int?
    var teeName: String?
    var latitude: Double?
    var longitude: Double?

    var hasEnrichedData: Bool {
        par != nil || courseRating != nil || slope != nil || totalYards != nil
    }

    var hasCoordinates: Bool {
        latitude != nil && longitude != nil
    }

    init(
        id: UUID = UUID(),
        name: String,
        city: String,
        state: String,
        courseType: CourseType,
        holeCount: Int = 18,
        notes: String? = nil,
        rating: Rating,
        rankPosition: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        country: String? = nil,
        par: Int? = nil,
        courseRating: Double? = nil,
        slope: Int? = nil,
        totalYards: Int? = nil,
        golfCourseApiId: Int? = nil,
        teeName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.courseType = courseType
        self.holeCount = holeCount
        self.notes = notes
        self.rating = rating
        self.rankPosition = rankPosition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.country = country
        self.par = par
        self.courseRating = courseRating
        self.slope = slope
        self.totalYards = totalYards
        self.golfCourseApiId = golfCourseApiId
        self.teeName = teeName
        self.latitude = latitude
        self.longitude = longitude
    }

    /// Formatted location string, showing country only when it differs from the user's locale.
    var locationText: String {
        Self.formatLocation(city: city, state: state, country: country)
    }

    static func formatLocation(city: String, state: String, country: String?) -> String {
        var parts = [city]
        if !state.isEmpty { parts.append(state) }
        if let country, !country.isEmpty, !isHomeCountry(country) {
            parts.append(country)
        }
        return parts.joined(separator: ", ")
    }

    private static func isHomeCountry(_ country: String) -> Bool {
        guard let regionCode = Locale.current.region?.identifier,
              let localeName = Locale.current.localizedString(forRegionCode: regionCode) else {
            return false
        }
        return country.lowercased() == localeName.lowercased()
    }
}
