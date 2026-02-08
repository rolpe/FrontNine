//
//  GolfCourseAPIModels.swift
//  Front Nine
//

import Foundation

// MARK: - Search Response

struct GolfCourseAPISearchResponse: Codable, Sendable {
    let courses: [GolfCourseAPICourse]
}

// MARK: - Course

struct GolfCourseAPICourse: Codable, Identifiable, Sendable {
    let id: Int
    let clubName: String
    let courseName: String
    let location: GolfCourseAPILocation
    let tees: GolfCourseAPITees

    enum CodingKeys: String, CodingKey {
        case id
        case clubName = "club_name"
        case courseName = "course_name"
        case location, tees
    }
}

// MARK: - Location

struct GolfCourseAPILocation: Codable, Sendable {
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Tees

struct GolfCourseAPITees: Codable, Sendable {
    let female: [GolfCourseAPITeeBox]?
    let male: [GolfCourseAPITeeBox]?
}

// MARK: - Tee Box

struct GolfCourseAPITeeBox: Codable, Identifiable, Equatable, Sendable {
    var id: String { teeName }

    let teeName: String
    let courseRating: Double?
    let slopeRating: Int?
    let bogeyRating: Double?
    let totalYards: Int?
    let totalMeters: Int?
    let numberOfHoles: Int?
    let parTotal: Int?

    enum CodingKeys: String, CodingKey {
        case teeName = "tee_name"
        case courseRating = "course_rating"
        case slopeRating = "slope_rating"
        case bogeyRating = "bogey_rating"
        case totalYards = "total_yards"
        case totalMeters = "total_meters"
        case numberOfHoles = "number_of_holes"
        case parTotal = "par_total"
    }
}
