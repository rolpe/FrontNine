//
//  CourseDeleter.swift
//  Front Nine

import SwiftData

struct CourseDeleter {

    /// Closes the rank gap left by removing a course from its current position.
    /// Shifts all courses ranked below it up by 1. Does NOT delete the course.
    static func closeRankGap(for course: Course, in allCourses: [Course]) {
        let removedRank = course.rankPosition
        for c in allCourses where c.rankPosition > removedRank && c.id != course.id {
            c.rankPosition -= 1
        }
    }

    /// Closes the rank gap, then deletes the course from the model context.
    static func deleteCourse(
        _ course: Course,
        allCourses: [Course],
        modelContext: ModelContext
    ) {
        closeRankGap(for: course, in: allCourses)
        modelContext.delete(course)
    }
}
