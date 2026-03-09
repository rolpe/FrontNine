//
//  AddCourseViewModelTests.swift
//  Front NineTests

import Testing
@testable import Front_Nine

struct AddCourseViewModelTests {

    // MARK: - isValid

    @Test func invalidWhenAllFieldsEmpty() {
        let vm = AddCourseViewModel()
        #expect(!vm.isValid)
    }

    @Test func invalidWhenNameEmpty() {
        let vm = AddCourseViewModel()
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(!vm.isValid)
    }

    @Test func invalidWhenCityEmpty() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(!vm.isValid)
    }

    @Test func validWhenStateEmpty() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.city = "Austin"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(vm.isValid) // State is optional for international courses
    }

    @Test func invalidWhenCourseTypeNil() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = nil
        vm.selectedRating = .liked
        #expect(!vm.isValid)
    }

    @Test func invalidWhenRatingNil() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = .public
        #expect(!vm.isValid)
    }

    @Test func validWhenAllFieldsFilled() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(vm.isValid)
    }

    @Test func invalidWhenNameIsOnlyWhitespace() {
        let vm = AddCourseViewModel()
        vm.courseName = "   "
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(!vm.isValid)
    }

    @Test func invalidWhenCityIsOnlyWhitespace() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test Course"
        vm.city = "   "
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        #expect(!vm.isValid)
    }

    // MARK: - buildCourse

    @Test func buildCourseReturnsNilWhenInvalid() {
        let vm = AddCourseViewModel()
        #expect(vm.buildCourse() == nil)
    }

    @Test func buildCourseReturnsCorrectProperties() {
        let vm = AddCourseViewModel()
        vm.courseName = "  Pebble Beach  "
        vm.city = "  Pebble Beach  "
        vm.state = "CA"
        vm.courseType = .public
        vm.holeCount = 18
        vm.notes = "  Beautiful course  "
        vm.selectedRating = .loved

        let course = vm.buildCourse()
        #expect(course != nil)
        #expect(course?.name == "Pebble Beach")
        #expect(course?.city == "Pebble Beach")
        #expect(course?.state == "CA")
        #expect(course?.courseType == .public)
        #expect(course?.holeCount == 18)
        #expect(course?.notes == "Beautiful course")
        #expect(course?.rating == .loved)
        #expect(course?.rankPosition == 0)
    }

    @Test func buildCourseNilNotesWhenEmpty() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test"
        vm.city = "City"
        vm.state = "TX"
        vm.courseType = .public
        vm.selectedRating = .liked
        vm.notes = "   "

        let course = vm.buildCourse()
        #expect(course?.notes == nil)
    }

    @Test func buildCoursePreservesNineHolesAndPrivate() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test"
        vm.city = "City"
        vm.state = "TX"
        vm.courseType = .private
        vm.holeCount = 9
        vm.selectedRating = .disliked

        let course = vm.buildCourse()
        #expect(course?.holeCount == 9)
        #expect(course?.courseType == .private)
        #expect(course?.rating == .disliked)
    }

    // MARK: - reset

    @Test func resetClearsAllFields() {
        let vm = AddCourseViewModel()
        vm.courseName = "Test"
        vm.city = "Austin"
        vm.state = "TX"
        vm.courseType = .public
        vm.holeCount = 9
        vm.notes = "Great"
        vm.selectedRating = .loved

        vm.reset()

        #expect(vm.courseName == "")
        #expect(vm.city == "")
        #expect(vm.state == "")
        #expect(vm.courseType == .public)
        #expect(vm.holeCount == 18)
        #expect(vm.notes == "")
        #expect(vm.selectedRating == nil)
    }
}
