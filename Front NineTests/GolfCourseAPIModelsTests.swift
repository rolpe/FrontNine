//
//  GolfCourseAPIModelsTests.swift
//  Front Nine
//

import Foundation
import Testing
@testable import Front_Nine

@Suite("GolfCourseAPI Models")
struct GolfCourseAPIModelsTests {

    // MARK: - Search Response

    @Test func decodesSearchResponse() throws {
        let json = """
        {
            "courses": [
                {
                    "id": 34,
                    "club_name": "Pebble Beach Golf Links",
                    "course_name": "Pebble Beach Golf Links",
                    "location": {
                        "address": "1700 17-Mile Dr, Pebble Beach, CA 93953",
                        "city": "Pebble Beach",
                        "state": "CA",
                        "country": "United States",
                        "latitude": 36.5668,
                        "longitude": -121.9486
                    },
                    "tees": {
                        "male": [
                            {
                                "tee_name": "Blue",
                                "course_rating": 75.5,
                                "slope_rating": 145,
                                "bogey_rating": 106.7,
                                "total_yards": 6828,
                                "total_meters": 6244,
                                "number_of_holes": 18,
                                "par_total": 72
                            }
                        ],
                        "female": []
                    }
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GolfCourseAPISearchResponse.self, from: json)
        #expect(response.courses.count == 1)

        let course = response.courses[0]
        #expect(course.id == 34)
        #expect(course.clubName == "Pebble Beach Golf Links")
        #expect(course.courseName == "Pebble Beach Golf Links")
        #expect(course.location.city == "Pebble Beach")
        #expect(course.location.state == "CA")
        #expect(course.location.country == "United States")
    }

    // MARK: - Tee Box Parsing

    @Test func decodesTeeBoxFields() throws {
        let json = """
        {
            "tee_name": "White",
            "course_rating": 73.8,
            "slope_rating": 138,
            "bogey_rating": 103.2,
            "total_yards": 6414,
            "total_meters": 5865,
            "number_of_holes": 18,
            "par_total": 72
        }
        """.data(using: .utf8)!

        let teeBox = try JSONDecoder().decode(GolfCourseAPITeeBox.self, from: json)
        #expect(teeBox.teeName == "White")
        #expect(teeBox.courseRating == 73.8)
        #expect(teeBox.slopeRating == 138)
        #expect(teeBox.bogeyRating == 103.2)
        #expect(teeBox.totalYards == 6414)
        #expect(teeBox.totalMeters == 5865)
        #expect(teeBox.numberOfHoles == 18)
        #expect(teeBox.parTotal == 72)
    }

    @Test func decodesMultipleTeeBoxes() throws {
        let json = """
        {
            "male": [
                {"tee_name": "Blue", "course_rating": 75.5, "slope_rating": 145, "total_yards": 6828, "par_total": 72},
                {"tee_name": "White", "course_rating": 73.8, "slope_rating": 138, "total_yards": 6414, "par_total": 72}
            ],
            "female": [
                {"tee_name": "Red", "course_rating": 72.1, "slope_rating": 130, "total_yards": 5574, "par_total": 72}
            ]
        }
        """.data(using: .utf8)!

        let tees = try JSONDecoder().decode(GolfCourseAPITees.self, from: json)
        #expect(tees.male?.count == 2)
        #expect(tees.female?.count == 1)
        #expect(tees.male?[0].teeName == "Blue")
        #expect(tees.male?[1].teeName == "White")
        #expect(tees.female?[0].teeName == "Red")
    }

    // MARK: - Optional Field Handling

    @Test func handlesMissingOptionalFields() throws {
        let json = """
        {
            "tee_name": "Gold",
            "par_total": 72
        }
        """.data(using: .utf8)!

        let teeBox = try JSONDecoder().decode(GolfCourseAPITeeBox.self, from: json)
        #expect(teeBox.teeName == "Gold")
        #expect(teeBox.parTotal == 72)
        #expect(teeBox.courseRating == nil)
        #expect(teeBox.slopeRating == nil)
        #expect(teeBox.totalYards == nil)
    }

    @Test func handlesNullLocationFields() throws {
        let json = """
        {
            "address": null,
            "city": null,
            "state": null,
            "country": null,
            "latitude": null,
            "longitude": null
        }
        """.data(using: .utf8)!

        let location = try JSONDecoder().decode(GolfCourseAPILocation.self, from: json)
        #expect(location.address == nil)
        #expect(location.city == nil)
        #expect(location.state == nil)
    }

    @Test func handlesEmptyCoursesArray() throws {
        let json = """
        { "courses": [] }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GolfCourseAPISearchResponse.self, from: json)
        #expect(response.courses.isEmpty)
    }

    @Test func handlesEmptyTeesArrays() throws {
        let json = """
        { "male": [], "female": null }
        """.data(using: .utf8)!

        let tees = try JSONDecoder().decode(GolfCourseAPITees.self, from: json)
        #expect(tees.male?.isEmpty == true)
        #expect(tees.female == nil)
    }

    // MARK: - Identifiable

    @Test func teeBoxIdIsTeeName() {
        let teeBox = GolfCourseAPITeeBox(
            teeName: "White",
            courseRating: 73.8,
            slopeRating: 138,
            bogeyRating: nil,
            totalYards: 6414,
            totalMeters: nil,
            numberOfHoles: 18,
            parTotal: 72
        )
        #expect(teeBox.id == "White")
    }
}
