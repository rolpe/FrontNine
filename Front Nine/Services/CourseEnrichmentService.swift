//
//  CourseEnrichmentService.swift
//  Front Nine
//

import Foundation

/// Orchestrates GolfCourseAPI lookup and tee box selection for the add-course flow.
@MainActor @Observable
class CourseEnrichmentService {

    // MARK: - Published State

    var isLoading = false
    var matchedCourse: GolfCourseAPICourse?
    var matchCandidates: [GolfCourseAPICourse]?
    var selectedTeeBox: GolfCourseAPITeeBox?

    // MARK: - Dependencies

    private let apiService: GolfCourseAPIService

    init(apiService: GolfCourseAPIService? = nil) {
        self.apiService = apiService ?? GolfCourseAPIService(apiKey: Secrets.golfCourseAPIKey)
    }

    // MARK: - Computed

    var availableTeeBoxes: [GolfCourseAPITeeBox] {
        guard let course = matchedCourse else { return [] }
        return course.tees.male ?? []
    }

    var enrichmentData: CourseEnrichmentData? {
        guard let course = matchedCourse, let tee = selectedTeeBox else { return nil }
        return CourseEnrichmentData(
            golfCourseApiId: course.id,
            par: tee.parTotal,
            courseRating: tee.courseRating,
            slope: tee.slopeRating,
            totalYards: tee.totalYards,
            teeName: tee.teeName,
            numberOfHoles: tee.numberOfHoles
        )
    }

    // MARK: - Actions

    func enrich(searchResult: CourseSearchResult) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let query = Self.cleanSearchQuery(searchResult.name)
            let courses = try await apiService.search(query: query)
            let result = Self.findMatch(in: courses, city: searchResult.city)

            switch result {
            case .none:
                matchedCourse = nil
                matchCandidates = nil
            case .matched(let course):
                applyMatch(course)
            case .ambiguous(let candidates):
                matchedCourse = nil
                matchCandidates = candidates
            }
        } catch {
            // Enrichment is optional — fail silently
            matchedCourse = nil
            matchCandidates = nil
        }
    }

    func selectCourse(_ course: GolfCourseAPICourse) {
        matchCandidates = nil
        applyMatch(course)
    }

    func selectTeeBox(_ teeBox: GolfCourseAPITeeBox) {
        selectedTeeBox = teeBox
    }

    // MARK: - Matching Logic (internal for testability)

    enum MatchResult: Equatable {
        case none
        case matched(GolfCourseAPICourse)
        case ambiguous([GolfCourseAPICourse])

        static func == (lhs: MatchResult, rhs: MatchResult) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.matched(let a), .matched(let b)):
                return a.id == b.id
            case (.ambiguous(let a), .ambiguous(let b)):
                return a.map(\.id) == b.map(\.id)
            default:
                return false
            }
        }
    }

    static func findMatch(in courses: [GolfCourseAPICourse], city: String) -> MatchResult {
        if courses.isEmpty { return .none }
        if courses.count == 1 { return .matched(courses[0]) }

        // Filter by city match (case-insensitive)
        let cityMatches = courses.filter {
            $0.location.city?.lowercased() == city.lowercased()
        }

        if cityMatches.count == 1 {
            return .matched(cityMatches[0])
        } else if cityMatches.isEmpty {
            // No city match — return all as ambiguous
            return .ambiguous(courses)
        } else {
            // Multiple city matches — still ambiguous (multi-course club)
            return .ambiguous(cityMatches)
        }
    }

    /// Strips common golf suffixes from a MapKit name to improve API search matching.
    /// e.g. "Liberty National Golf Course" → "Liberty National"
    static func cleanSearchQuery(_ name: String) -> String {
        let suffixes = [
            "Golf & Country Club",
            "Golf and Country Club",
            "Golf Country Club",
            "Country Club",
            "Golf Course",
            "Golf Club",
            "Golf Links",
            "Golf Center",
            "Golf Resort",
        ]

        var cleaned = name
        for suffix in suffixes {
            if cleaned.lowercased().hasSuffix(suffix.lowercased()) {
                cleaned = String(cleaned.dropLast(suffix.count))
                    .trimmingCharacters(in: .whitespaces)
                break
            }
        }

        return cleaned.isEmpty ? name : cleaned
    }

    static func defaultTeeBox(from tees: GolfCourseAPITees) -> GolfCourseAPITeeBox? {
        guard let maleTees = tees.male, !maleTees.isEmpty else {
            return tees.female?.first
        }

        // Prefer "White" tee
        if let white = maleTees.first(where: { $0.teeName.lowercased() == "white" }) {
            return white
        }

        // Fallback: middle tee by yardage
        let sorted = maleTees.sorted { ($0.totalYards ?? 0) < ($1.totalYards ?? 0) }
        return sorted[sorted.count / 2]
    }

    // MARK: - Private

    private func applyMatch(_ course: GolfCourseAPICourse) {
        matchedCourse = course
        selectedTeeBox = Self.defaultTeeBox(from: course.tees)
    }
}
