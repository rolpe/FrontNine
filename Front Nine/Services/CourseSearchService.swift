//
//  CourseSearchService.swift
//  Front Nine
//

import CoreLocation
import MapKit

actor CourseSearchService {

    func search(query: String) async throws -> [CourseSearchResult] {
        // Three parallel searches to maximize coverage:
        // 1. Golf-filtered + " golf" appended — best for typical queries ("Pebble Beach")
        // 2. Golf-filtered with exact query — catches courses with generic names ("The Park")
        // 3. Unfiltered + " golf" appended — catches miscategorized courses ("Montauk Downs")
        let golfQuery = query + " golf"

        async let filteredAppended = golfFilteredSearch(query: golfQuery)
        async let filteredExact = golfFilteredSearch(query: query)
        async let broad = unfilteredSearch(query: golfQuery)

        let results1 = (try? await filteredAppended) ?? []
        let results2 = (try? await filteredExact) ?? []
        let results3 = (try? await broad) ?? []

        // If all empty, return empty — ViewModel shows "No courses found" state
        if results1.isEmpty && results2.isEmpty && results3.isEmpty {
            return []
        }

        // Merge in priority order, deduplicate by id (name+coordinates) and by name+city
        var seenIds = Set<String>()
        var seenNameCity = Set<String>()
        var merged: [CourseSearchResult] = []
        for course in results1 + results2 + results3 {
            let nameCityKey = "\(course.name.lowercased())|\(course.city.lowercased())"
            guard seenIds.insert(course.id).inserted,
                  seenNameCity.insert(nameCityKey).inserted else { continue }
            merged.append(course)
        }
        return merged
    }

    private func golfFilteredSearch(query: String) async throws -> [CourseSearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.golf])

        let response = try await MKLocalSearch(request: request).start()
        return await MainActor.run {
            response.mapItems.compactMap { CourseSearchResult.from(mapItem: $0) }
        }
    }

    /// Categories that could plausibly contain a golf course — allowlist is safer than blocklist
    /// since new Apple categories default to excluded rather than slipping through.
    private static let allowedBroadCategories: Set<MKPointOfInterestCategory> = [
        .golf, .park, .nationalPark, .campground
    ]

    private func unfilteredSearch(query: String) async throws -> [CourseSearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest

        let response = try await MKLocalSearch(request: request).start()
        let allowed = Self.allowedBroadCategories
        return await MainActor.run {
            response.mapItems
                .filter { item in
                    guard let category = item.pointOfInterestCategory else { return true }
                    return allowed.contains(category)
                }
                .compactMap { CourseSearchResult.from(mapItem: $0) }
        }
    }

    func searchNearby(coordinate: CLLocationCoordinate2D) async throws -> [CourseSearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "golf"
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.golf])
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 10_000,
            longitudinalMeters: 10_000
        )

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return await MainActor.run {
            response.mapItems.compactMap { CourseSearchResult.from(mapItem: $0) }
        }
    }
}
