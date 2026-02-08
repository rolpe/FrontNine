//
//  CourseSearchResult.swift
//  Front Nine
//

import Foundation
import MapKit

struct CourseSearchResult: Identifiable, Equatable {
    let id: String
    let name: String
    let city: String
    let state: String
    let country: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CourseSearchResult, rhs: CourseSearchResult) -> Bool {
        lhs.id == rhs.id
    }

    @MainActor
    static func from(mapItem: MKMapItem) -> CourseSearchResult? {
        guard let name = mapItem.name else { return nil }

        let city: String
        let region: String
        let countryName: String
        let coord: CLLocationCoordinate2D

        if #available(iOS 26, *) {
            coord = mapItem.location.coordinate
            guard let reps = mapItem.addressRepresentations,
                  let cityName = reps.cityName else { return nil }
            city = cityName
            countryName = reps.regionName ?? ""
            // Extract region from "City, Region" format, fall back to country
            if let cityWithCtx = reps.cityWithContext {
                let parts = cityWithCtx.components(separatedBy: ", ")
                region = parts.count >= 2 ? parts.dropFirst().joined(separator: ", ") : ""
            } else {
                region = ""
            }
        } else {
            let placemark = mapItem.placemark
            guard let c = placemark.locality else { return nil }
            city = c
            coord = placemark.coordinate
            countryName = placemark.country ?? ""
            // Use admin area (state/province), fall back to country
            if let adminArea = placemark.administrativeArea {
                region = adminArea
            } else {
                region = ""
            }
        }

        // For US states given as full names, abbreviate for consistency
        let state: String
        if let abbrev = USState.abbreviation(for: region) {
            state = abbrev
        } else {
            state = region
        }

        let id = "\(name)|\(coord.latitude)|\(coord.longitude)"

        return CourseSearchResult(
            id: id,
            name: name,
            city: city,
            state: state,
            country: countryName,
            coordinate: coord
        )
    }
}
