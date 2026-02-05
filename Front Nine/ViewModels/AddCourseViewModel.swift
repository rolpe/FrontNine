//
//  AddCourseViewModel.swift
//  Front Nine
//

import SwiftUI

@Observable
final class AddCourseViewModel {
    var courseName: String = ""
    var city: String = ""
    var state: String = ""
    var courseType: CourseType? = nil
    var holeCount: Int = 18
    var notes: String = ""
    var selectedRating: Rating? = nil

    var isValid: Bool {
        !courseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !state.isEmpty &&
        courseType != nil &&
        selectedRating != nil
    }

    var trimmedName: String { courseName.trimmingCharacters(in: .whitespaces) }
    var trimmedCity: String { city.trimmingCharacters(in: .whitespaces) }
    var trimmedNotes: String? {
        let t = notes.trimmingCharacters(in: .whitespaces)
        return t.isEmpty ? nil : t
    }

    func buildCourse() -> Course? {
        guard isValid, let courseType, let selectedRating else { return nil }
        return Course(
            name: trimmedName,
            city: trimmedCity,
            state: state,
            courseType: courseType,
            holeCount: holeCount,
            notes: trimmedNotes,
            rating: selectedRating,
            rankPosition: 0
        )
    }

    func reset() {
        courseName = ""
        city = ""
        state = ""
        courseType = nil
        holeCount = 18
        notes = ""
        selectedRating = nil
    }
}
