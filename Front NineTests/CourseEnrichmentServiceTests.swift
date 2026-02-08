//
//  CourseEnrichmentServiceTests.swift
//  Front Nine
//

import Foundation
import Testing
@testable import Front_Nine

@Suite("CourseEnrichmentService") @MainActor
struct CourseEnrichmentServiceTests {

    // MARK: - Helpers

    private func makeCourse(
        id: Int = 1,
        clubName: String = "Test Club",
        courseName: String = "Test Course",
        city: String = "Springfield",
        state: String = "IL",
        maleTees: [GolfCourseAPITeeBox]? = nil,
        femaleTees: [GolfCourseAPITeeBox]? = nil
    ) -> GolfCourseAPICourse {
        GolfCourseAPICourse(
            id: id,
            clubName: clubName,
            courseName: courseName,
            location: GolfCourseAPILocation(
                address: nil,
                city: city,
                state: state,
                country: "United States",
                latitude: nil,
                longitude: nil
            ),
            tees: GolfCourseAPITees(female: femaleTees, male: maleTees)
        )
    }

    private func makeTeeBox(
        name: String,
        courseRating: Double? = nil,
        slopeRating: Int? = nil,
        totalYards: Int? = nil,
        parTotal: Int? = 72
    ) -> GolfCourseAPITeeBox {
        GolfCourseAPITeeBox(
            teeName: name,
            courseRating: courseRating,
            slopeRating: slopeRating,
            bogeyRating: nil,
            totalYards: totalYards,
            totalMeters: nil,
            numberOfHoles: 18,
            parTotal: parTotal
        )
    }

    // MARK: - findMatch

    @Test func findMatchReturnsNoneForEmptyResults() {
        let result = CourseEnrichmentService.findMatch(in: [], city: "Springfield")
        #expect(result == .none)
    }

    @Test func findMatchAutoMatchesSingleResult() {
        let course = makeCourse(id: 42, city: "Somewhere Else")
        let result = CourseEnrichmentService.findMatch(in: [course], city: "Springfield")
        #expect(result == .matched(course))
    }

    @Test func findMatchAutoMatchesByCityWhenOneCityMatch() {
        let courseA = makeCourse(id: 1, courseName: "Course A", city: "Springfield")
        let courseB = makeCourse(id: 2, courseName: "Course B", city: "Shelbyville")
        let result = CourseEnrichmentService.findMatch(in: [courseA, courseB], city: "Springfield")
        #expect(result == .matched(courseA))
    }

    @Test func findMatchCityComparisonIsCaseInsensitive() {
        let course = makeCourse(id: 1, city: "pebble beach")
        let other = makeCourse(id: 2, city: "Monterey")
        let result = CourseEnrichmentService.findMatch(in: [course, other], city: "Pebble Beach")
        #expect(result == .matched(course))
    }

    @Test func findMatchReturnsAmbiguousForMultipleCityMatches() {
        let courseA = makeCourse(id: 1, courseName: "Course 1", city: "Pinehurst")
        let courseB = makeCourse(id: 2, courseName: "Course 2", city: "Pinehurst")
        let result = CourseEnrichmentService.findMatch(in: [courseA, courseB], city: "Pinehurst")
        #expect(result == .ambiguous([courseA, courseB]))
    }

    @Test func findMatchReturnsAllAsAmbiguousWhenNoCityMatch() {
        let courseA = makeCourse(id: 1, city: "City A")
        let courseB = makeCourse(id: 2, city: "City B")
        let result = CourseEnrichmentService.findMatch(in: [courseA, courseB], city: "Springfield")
        #expect(result == .ambiguous([courseA, courseB]))
    }

    // MARK: - defaultTeeBox

    @Test func defaultTeeBoxPrefersWhite() {
        let blue = makeTeeBox(name: "Blue", totalYards: 6800)
        let white = makeTeeBox(name: "White", totalYards: 6400)
        let red = makeTeeBox(name: "Red", totalYards: 5400)
        let tees = GolfCourseAPITees(female: nil, male: [blue, white, red])

        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result?.teeName == "White")
    }

    @Test func defaultTeeBoxPrefersWhiteCaseInsensitive() {
        let championship = makeTeeBox(name: "Championship", totalYards: 7200)
        let white = makeTeeBox(name: "white", totalYards: 6400)
        let tees = GolfCourseAPITees(female: nil, male: [championship, white])

        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result?.teeName == "white")
    }

    @Test func defaultTeeBoxFallsBackToMiddleByYardage() {
        let gold = makeTeeBox(name: "Gold", totalYards: 7000)
        let blue = makeTeeBox(name: "Blue", totalYards: 6500)
        let red = makeTeeBox(name: "Red", totalYards: 5500)
        let tees = GolfCourseAPITees(female: nil, male: [gold, blue, red])

        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result?.teeName == "Blue")
    }

    @Test func defaultTeeBoxFallsToFemaleWhenNoMale() {
        let red = makeTeeBox(name: "Red", totalYards: 5400)
        let tees = GolfCourseAPITees(female: [red], male: nil)

        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result?.teeName == "Red")
    }

    @Test func defaultTeeBoxReturnsNilForEmptyTees() {
        let tees = GolfCourseAPITees(female: nil, male: nil)
        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result == nil)
    }

    @Test func defaultTeeBoxReturnsNilForEmptyArrays() {
        let tees = GolfCourseAPITees(female: [], male: [])
        let result = CourseEnrichmentService.defaultTeeBox(from: tees)
        #expect(result == nil)
    }

    // MARK: - enrichmentData

    @Test func enrichmentDataIsComputedFromMatchAndTee() {
        let service = CourseEnrichmentService()
        let tee = makeTeeBox(
            name: "White",
            courseRating: 73.8,
            slopeRating: 138,
            totalYards: 6414,
            parTotal: 72
        )
        let course = makeCourse(id: 99, maleTees: [tee])

        service.selectCourse(course)

        let data = service.enrichmentData
        #expect(data != nil)
        #expect(data?.golfCourseApiId == 99)
        #expect(data?.par == 72)
        #expect(data?.courseRating == 73.8)
        #expect(data?.slope == 138)
        #expect(data?.totalYards == 6414)
        #expect(data?.teeName == "White")
    }

    @Test func enrichmentDataIsNilWhenNoMatch() {
        let service = CourseEnrichmentService()
        #expect(service.enrichmentData == nil)
    }

    // MARK: - selectCourse

    @Test func selectCourseSetsMatchAndDefaultTee() {
        let service = CourseEnrichmentService()
        let white = makeTeeBox(name: "White", totalYards: 6400)
        let blue = makeTeeBox(name: "Blue", totalYards: 6800)
        let course = makeCourse(id: 5, maleTees: [blue, white])

        service.selectCourse(course)

        #expect(service.matchedCourse?.id == 5)
        #expect(service.selectedTeeBox?.teeName == "White")
        #expect(service.matchCandidates == nil)
    }

    @Test func selectTeeBoxUpdatesSelection() {
        let service = CourseEnrichmentService()
        let white = makeTeeBox(name: "White", totalYards: 6400)
        let blue = makeTeeBox(name: "Blue", totalYards: 6800)
        let course = makeCourse(id: 5, maleTees: [blue, white])

        service.selectCourse(course)
        #expect(service.selectedTeeBox?.teeName == "White")

        service.selectTeeBox(blue)
        #expect(service.selectedTeeBox?.teeName == "Blue")
        #expect(service.enrichmentData?.totalYards == 6800)
    }

    // MARK: - availableTeeBoxes

    @Test func availableTeeBoxesReturnsMaleTees() {
        let service = CourseEnrichmentService()
        let white = makeTeeBox(name: "White")
        let blue = makeTeeBox(name: "Blue")
        let course = makeCourse(maleTees: [white, blue])

        service.selectCourse(course)

        #expect(service.availableTeeBoxes.count == 2)
        #expect(service.availableTeeBoxes[0].teeName == "White")
    }

    @Test func availableTeeBoxesIsEmptyWithNoMatch() {
        let service = CourseEnrichmentService()
        #expect(service.availableTeeBoxes.isEmpty)
    }
}

// MARK: - Course.hasEnrichedData

@Suite("Course Enrichment Fields")
struct CourseEnrichmentFieldsTests {

    @Test func hasEnrichedDataWhenParSet() {
        let course = Course(name: "Test", city: "City", state: "ST", courseType: .public, rating: .liked, par: 72)
        #expect(course.hasEnrichedData)
    }

    @Test func hasEnrichedDataWhenSlopeSet() {
        let course = Course(name: "Test", city: "City", state: "ST", courseType: .public, rating: .liked, slope: 138)
        #expect(course.hasEnrichedData)
    }

    @Test func hasEnrichedDataWhenYardsSet() {
        let course = Course(name: "Test", city: "City", state: "ST", courseType: .public, rating: .liked, totalYards: 6400)
        #expect(course.hasEnrichedData)
    }

    @Test func noEnrichedDataWhenAllNil() {
        let course = Course(name: "Test", city: "City", state: "ST", courseType: .public, rating: .liked)
        #expect(!course.hasEnrichedData)
    }
}
