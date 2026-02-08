//
//  AddCourseViewModel.swift
//  Front Nine
//

import SwiftUI

private let defaultCountry: String = {
    guard let regionCode = Locale.current.region?.identifier else { return "" }
    return Locale.current.localizedString(forRegionCode: regionCode) ?? ""
}()

@Observable
final class AddCourseViewModel {
    var courseName: String = ""
    var city: String = ""
    var state: String = ""
    var country: String = defaultCountry
    var courseType: CourseType? = nil
    var holeCount: Int = 18
    var notes: String = ""
    var selectedRating: Rating? = nil

    var isValid: Bool {
        !courseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
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
        let trimmedCountry = country.trimmingCharacters(in: .whitespaces)
        return Course(
            name: trimmedName,
            city: trimmedCity,
            state: state,
            courseType: courseType,
            holeCount: holeCount,
            notes: trimmedNotes,
            rating: selectedRating,
            rankPosition: 0,
            country: trimmedCountry.isEmpty ? nil : trimmedCountry
        )
    }

    func reset() {
        courseName = ""
        city = ""
        state = ""
        country = defaultCountry
        courseType = nil
        holeCount = 18
        notes = ""
        selectedRating = nil
    }
}
