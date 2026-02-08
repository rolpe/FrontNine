//
//  CourseSearchService.swift
//  Front Nine
//

import CoreLocation
import MapKit

actor CourseSearchService {

    func search(query: String) async throws -> [CourseSearchResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query + " golf"
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.golf])

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return await MainActor.run {
            response.mapItems.compactMap { CourseSearchResult.from(mapItem: $0) }
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
