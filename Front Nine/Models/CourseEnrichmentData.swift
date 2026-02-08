//
//  CourseEnrichmentData.swift
//  Front Nine
//

import Foundation

/// Lightweight value type for passing enrichment data through the add-course flow.
/// Populated from GolfCourseAPI.com response + selected tee box.
struct CourseEnrichmentData {
    let golfCourseApiId: Int
    let par: Int?
    let courseRating: Double?
    let slope: Int?
    let totalYards: Int?
    let teeName: String?
}
