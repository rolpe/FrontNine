//
//  GolfCourseAPIService.swift
//  Front Nine
//

import Foundation

// MARK: - Errors

enum GolfCourseAPIError: Error, LocalizedError {
    case noAPIKey
    case rateLimited
    case notFound
    case httpError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .noAPIKey: "No API key configured."
        case .rateLimited: "API rate limit reached. Try again later."
        case .notFound: "Course not found."
        case .httpError(let code): "Server error (\(code))."
        case .networkError: "Network error. Check your connection."
        }
    }
}

// MARK: - Service

@MainActor
final class GolfCourseAPIService {
    private let baseURL = "https://api.golfcourseapi.com/v1"
    private let apiKey: String
    private let session: URLSession
    private var searchCache: [String: [GolfCourseAPICourse]] = [:]

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: - Search

    func search(query: String) async throws -> [GolfCourseAPICourse] {
        let cacheKey = query.lowercased().trimmingCharacters(in: .whitespaces)
        if let cached = searchCache[cacheKey] {
            return cached
        }

        guard !apiKey.isEmpty else { throw GolfCourseAPIError.noAPIKey }

        guard var components = URLComponents(string: "\(baseURL)/search") else {
            throw GolfCourseAPIError.networkError(URLError(.badURL))
        }
        components.queryItems = [URLQueryItem(name: "search_query", value: query)]

        guard let url = components.url else {
            throw GolfCourseAPIError.networkError(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        let searchResponse = try JSONDecoder().decode(GolfCourseAPISearchResponse.self, from: data)

        searchCache[cacheKey] = searchResponse.courses
        return searchResponse.courses
    }

    // MARK: - Fetch by ID

    func fetchCourse(id: Int) async throws -> GolfCourseAPICourse {
        guard !apiKey.isEmpty else { throw GolfCourseAPIError.noAPIKey }

        guard let url = URL(string: "\(baseURL)/courses/\(id)") else {
            throw GolfCourseAPIError.networkError(URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)

        return try JSONDecoder().decode(GolfCourseAPICourse.self, from: data)
    }

    // MARK: - Helpers

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        switch httpResponse.statusCode {
        case 200..<300: return
        case 401: throw GolfCourseAPIError.noAPIKey
        case 404: throw GolfCourseAPIError.notFound
        case 429: throw GolfCourseAPIError.rateLimited
        default: throw GolfCourseAPIError.httpError(httpResponse.statusCode)
        }
    }
}
