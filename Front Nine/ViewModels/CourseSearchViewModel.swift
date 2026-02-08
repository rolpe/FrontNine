//
//  CourseSearchViewModel.swift
//  Front Nine
//

import CoreLocation
import Foundation
import MapKit

@Observable
final class CourseSearchViewModel {
    var query: String = ""
    var results: [CourseSearchResult] = []
    var isSearching: Bool = false
    var searchError: String?
    var recentSearches: [String] = []

    // Nearby
    let locationManager = LocationManager()
    var nearbyResults: [CourseSearchResult] = []
    var isLoadingNearby: Bool = false
    var nearbyError: String?
    private var hasLoadedNearby = false

    private let searchService = CourseSearchService()
    private let defaults: UserDefaults
    private var existingCourseKeys: Set<String> = []

    static let recentSearchesKey = "com.frontnine.recentSearches"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.recentSearches = defaults.stringArray(forKey: Self.recentSearchesKey) ?? []
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            isSearching = false
            searchError = nil
            return
        }

        isSearching = true
        searchError = nil

        do {
            let found = try await searchService.search(query: trimmed)
            if !Task.isCancelled {
                results = found
                isSearching = false
                saveRecentSearch(trimmed)
            }
        } catch let error as MKError where error.code == .placemarkNotFound {
            // MapKit throws this when no results are found — treat as empty results
            if !Task.isCancelled {
                results = []
                isSearching = false
                saveRecentSearch(trimmed)
            }
        } catch {
            if !Task.isCancelled {
                searchError = "Search failed. Check your connection."
                isSearching = false
                saveRecentSearch(trimmed)
            }
        }
    }

    // MARK: - Recent Searches

    func saveRecentSearch(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var searches = recentSearches
        searches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        searches.insert(trimmed, at: 0)
        if searches.count > 4 {
            searches = Array(searches.prefix(4))
        }
        recentSearches = searches
        defaults.set(searches, forKey: Self.recentSearchesKey)
    }

    // MARK: - Already-Added Detection

    func updateExistingCourses(_ courses: [Course]) {
        existingCourseKeys = Set(courses.map { Self.courseKey(name: $0.name, city: $0.city, state: $0.state) })
    }

    func isAlreadyAdded(_ result: CourseSearchResult) -> Bool {
        let key = Self.courseKey(name: result.name, city: result.city, state: result.state)
        return existingCourseKeys.contains(key)
    }

    static func courseKey(name: String, city: String, state: String) -> String {
        "\(name.trimmingCharacters(in: .whitespaces).lowercased())|\(city.trimmingCharacters(in: .whitespaces).lowercased())|\(state.trimmingCharacters(in: .whitespaces).lowercased())"
    }

    // MARK: - Nearby Courses

    /// Called on appear — auto-loads nearby if permission is already granted
    func loadNearbyIfAuthorized() async {
        guard !hasLoadedNearby else { return }
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            await searchNearby()
        }
    }

    /// Called when user taps "Find Nearby" — requests permission then loads
    func requestNearbyPermission() async {
        locationManager.requestPermission()

        // Wait for the authorization status to change
        // Poll briefly — the delegate updates authorizationStatus synchronously
        for _ in 0..<20 {
            try? await Task.sleep(for: .milliseconds(250))
            let status = locationManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                await searchNearby()
                return
            } else if status == .denied || status == .restricted {
                return
            }
        }
    }

    private func searchNearby() async {
        guard !isLoadingNearby else { return }
        isLoadingNearby = true
        nearbyError = nil

        do {
            let coordinate = try await locationManager.requestLocation()
            let found = try await searchService.searchNearby(coordinate: coordinate)
            nearbyResults = Array(found.prefix(5))
            hasLoadedNearby = true
        } catch let error as MKError where error.code == .placemarkNotFound {
            nearbyResults = []
            hasLoadedNearby = true
        } catch {
            nearbyError = "Couldn't find nearby courses."
        }

        isLoadingNearby = false
    }
}
