//
//  ProfileSetupViewModelTests.swift
//  Front NineTests

import Foundation
import Testing
@testable import Front_Nine

@MainActor
struct ProfileSetupViewModelTests {

    // MARK: - Helpers

    private func makeMock(handleAvailable: Bool = true) -> MockFirestoreService {
        let mock = MockFirestoreService()
        mock.handleAvailable = handleAvailable
        return mock
    }

    private func makeVM(handleAvailable: Bool = true) -> ProfileSetupViewModel {
        let mock = makeMock(handleAvailable: handleAvailable)
        let authService = AuthService(firestoreService: mock)
        return ProfileSetupViewModel(authService: authService)
    }

    // MARK: - sanitizedHandle

    @Test func sanitizedHandleLowercases() {
        let vm = makeVM()
        vm.handle = "TestUser"
        #expect(vm.sanitizedHandle == "testuser")
    }

    @Test func sanitizedHandleStripsSpecialChars() {
        let vm = makeVM()
        vm.handle = "test@user!#$"
        #expect(vm.sanitizedHandle == "testuser")
    }

    @Test func sanitizedHandleAllowsUnderscores() {
        let vm = makeVM()
        vm.handle = "test_user_123"
        #expect(vm.sanitizedHandle == "test_user_123")
    }

    @Test func sanitizedHandleTruncatesAt30() {
        let vm = makeVM()
        vm.handle = String(repeating: "a", count: 40)
        #expect(vm.sanitizedHandle.count == 30)
    }

    @Test func sanitizedHandleAllowsNumbers() {
        let vm = makeVM()
        vm.handle = "user42"
        #expect(vm.sanitizedHandle == "user42")
    }

    @Test func sanitizedHandleStripsSpaces() {
        let vm = makeVM()
        vm.handle = "test user"
        #expect(vm.sanitizedHandle == "testuser")
    }

    // MARK: - handleDidChange: synchronous validation

    @Test func emptyHandleSetsEmptyStatus() {
        let vm = makeVM()
        vm.handle = ""
        vm.handleDidChange()
        #expect(vm.handleStatus == .empty)
    }

    @Test func oneCharHandleIsTooShort() {
        let vm = makeVM()
        vm.handle = "a"
        vm.handleDidChange()
        #expect(vm.handleStatus == .tooShort)
    }

    @Test func twoCharHandleIsTooShort() {
        let vm = makeVM()
        vm.handle = "ab"
        vm.handleDidChange()
        #expect(vm.handleStatus == .tooShort)
    }

    @Test func threeCharHandleSetsChecking() {
        let vm = makeVM()
        vm.handle = "abc"
        vm.handleDidChange()
        #expect(vm.handleStatus == .checking)
    }

    @Test func validHandleSetsChecking() {
        let vm = makeVM()
        vm.handle = "valid_handle"
        vm.handleDidChange()
        #expect(vm.handleStatus == .checking)
    }

    @Test func unicodeLettersSetInvalid() {
        let vm = makeVM()
        vm.handle = "café"
        vm.handleDidChange()
        // sanitizedHandle keeps unicode letters (isLetter includes é)
        // but regex ^[a-z0-9_]{3,30}$ rejects them → .invalid
        #expect(vm.handleStatus == .invalid)
    }

    @Test func handleDidChangeSanitizesHandle() {
        let vm = makeVM()
        vm.handle = "TEST@123"
        vm.handleDidChange()
        #expect(vm.handle == "test123")
    }

    // MARK: - handleDidChange: async availability

    @Test func availableHandleAfterDebounce() async throws {
        let vm = makeVM(handleAvailable: true)
        vm.handle = "good_handle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(vm.handleStatus == .available)
    }

    @Test func takenHandleAfterDebounce() async throws {
        let vm = makeVM(handleAvailable: false)
        vm.handle = "taken_handle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(vm.handleStatus == .taken)
    }

    // MARK: - Debounce cancellation

    @Test func rapidChangesCancelPreviousChecks() async throws {
        let vm = makeVM(handleAvailable: true)

        vm.handle = "first"
        vm.handleDidChange()
        vm.handle = "second"
        vm.handleDidChange()
        vm.handle = "third"
        vm.handleDidChange()

        // Immediately after rapid changes, status should be .checking
        #expect(vm.handleStatus == .checking)

        // After debounce, final check should resolve
        try await Task.sleep(for: .milliseconds(700))
        #expect(vm.handleStatus == .available)
    }

    // MARK: - isValid

    @Test func isValidFalseWhenDisplayNameEmpty() async throws {
        let vm = makeVM(handleAvailable: true)
        vm.displayName = ""
        vm.handle = "good_handle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(!vm.isValid)
    }

    @Test func isValidFalseWhenDisplayNameWhitespace() async throws {
        let vm = makeVM(handleAvailable: true)
        vm.displayName = "   "
        vm.handle = "good_handle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(!vm.isValid)
    }

    @Test func isValidFalseWhenHandleTaken() async throws {
        let vm = makeVM(handleAvailable: false)
        vm.displayName = "Test User"
        vm.handle = "taken"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(!vm.isValid)
    }

    @Test func isValidFalseWhenHandleTooShort() {
        let vm = makeVM()
        vm.displayName = "Test User"
        vm.handle = "ab"
        vm.handleDidChange()

        #expect(!vm.isValid)
    }

    @Test func isValidTrueWhenNameAndHandleGood() async throws {
        let vm = makeVM(handleAvailable: true)
        vm.displayName = "Test User"
        vm.handle = "good_handle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        #expect(vm.isValid)
    }

    // MARK: - initialName

    @Test func initialNamePreFillsDisplayName() {
        let mock = makeMock()
        let authService = AuthService(firestoreService: mock)
        let vm = ProfileSetupViewModel(authService: authService, initialName: "Ron Lipkin")
        #expect(vm.displayName == "Ron Lipkin")
    }

    @Test func defaultInitialNameIsEmpty() {
        let vm = makeVM()
        #expect(vm.displayName == "")
    }

    // MARK: - save

    @Test func saveDoesNothingWhenInvalid() async {
        let vm = makeVM()
        vm.displayName = ""
        vm.handle = ""

        await vm.save()

        // Should not crash, isSaving should be false
        #expect(!vm.isSaving)
        #expect(vm.saveError == nil)
    }

    @Test func saveResetsSavingStateOnCompletion() async throws {
        let vm = makeVM(handleAvailable: true)
        vm.displayName = "Test"
        vm.handle = "testhandle"
        vm.handleDidChange()

        try await Task.sleep(for: .milliseconds(700))

        await vm.save()

        #expect(!vm.isSaving)
    }
}

// MARK: - Mock

@MainActor
final class MockFirestoreService: FirestoreServiceProtocol {
    var profileToReturn: UserProfile?
    var handleAvailable = true
    var shouldThrow = false
    var savedProfile: UserProfile?
    var deletedUID: String?

    func fetchUserProfile(uid: String) async throws -> UserProfile? {
        if shouldThrow { throw MockError.testError }
        return profileToReturn
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        if shouldThrow { throw MockError.testError }
        savedProfile = profile
    }

    func isHandleAvailable(_ handle: String, excludingUID uid: String?) async throws -> Bool {
        if shouldThrow { throw MockError.testError }
        return handleAvailable
    }

    func deleteUserProfile(uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        deletedUID = uid
    }

    enum MockError: Error { case testError }
}
