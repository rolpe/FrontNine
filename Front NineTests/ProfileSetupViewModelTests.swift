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

    // Rankings tracking
    var savedRankings: [(courseId: String, uid: String)] = []
    var deletedRankings: [(courseId: String, uid: String)] = []
    var batchSavedRankings: [[(courseId: String, data: [String: Any])]] = []
    var rankingsToReturn: [FirestoreRanking] = []

    // Profile
    func fetchUserProfile(uid: String) async throws -> UserProfile? {
        if shouldThrow { throw MockError.testError }
        return profileToReturn
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        if shouldThrow { throw MockError.testError }
        savedProfile = profile
    }

    var updatedFields: [(uid: String, field: String, value: Any)] = []

    func updateProfileField(uid: String, field: String, value: Any) async throws {
        if shouldThrow { throw MockError.testError }
        updatedFields.append((uid: uid, field: field, value: value))
    }

    func isHandleAvailable(_ handle: String, excludingUID uid: String?) async throws -> Bool {
        if shouldThrow { throw MockError.testError }
        return handleAvailable
    }

    func deleteUserProfile(uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        deletedUID = uid
    }

    // Rankings
    func saveRanking(_ ranking: FirestoreRanking, courseId: String, uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        savedRankings.append((courseId: courseId, uid: uid))
    }

    func deleteRanking(courseId: String, uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        deletedRankings.append((courseId: courseId, uid: uid))
    }

    func batchSaveRankings(_ rankings: [(courseId: String, data: [String: Any])], uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        batchSavedRankings.append(rankings)
    }

    func fetchRankings(uid: String) async throws -> [FirestoreRanking] {
        if shouldThrow { throw MockError.testError }
        return rankingsToReturn
    }

    // Follow tracking
    var followedPairs: [(currentUid: String, targetUid: String)] = []
    var unfollowedPairs: [(currentUid: String, targetUid: String)] = []
    var followingUidsToReturn: [String] = []
    var followerUidsToReturn: [String] = []
    var profilesToReturn: [UserProfile] = []
    var searchResultsToReturn: [UserProfile] = []

    func followUser(currentUid: String, targetUid: String) async throws {
        if shouldThrow { throw MockError.testError }
        followedPairs.append((currentUid: currentUid, targetUid: targetUid))
    }

    func unfollowUser(currentUid: String, targetUid: String) async throws {
        if shouldThrow { throw MockError.testError }
        unfollowedPairs.append((currentUid: currentUid, targetUid: targetUid))
    }

    func checkFollowing(currentUid: String, targetUid: String) async throws -> Bool {
        if shouldThrow { throw MockError.testError }
        return followingUidsToReturn.contains(targetUid)
    }

    func fetchFollowingUids(uid: String) async throws -> [String] {
        if shouldThrow { throw MockError.testError }
        return followingUidsToReturn
    }

    func fetchFollowerUids(uid: String) async throws -> [String] {
        if shouldThrow { throw MockError.testError }
        return followerUidsToReturn
    }

    func fetchUserProfiles(uids: [String]) async throws -> [UserProfile] {
        if shouldThrow { throw MockError.testError }
        return profilesToReturn.filter { uids.contains($0.uid) }
    }

    func searchUsers(query: String, limit: Int) async throws -> [UserProfile] {
        if shouldThrow { throw MockError.testError }
        return Array(searchResultsToReturn.prefix(limit))
    }

    // Activity tracking
    var savedActivities: [(data: [String: Any], uid: String)] = []
    var activityToReturn: [ActivityItem] = []

    func saveActivity(_ data: [String: Any], uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        savedActivities.append((data: data, uid: uid))
    }

    func fetchActivity(uid: String, limit: Int) async throws -> [ActivityItem] {
        if shouldThrow { throw MockError.testError }
        return Array(activityToReturn.prefix(limit))
    }

    var deletedActivityUids: [String] = []

    func deleteAllActivity(uid: String) async throws {
        if shouldThrow { throw MockError.testError }
        deletedActivityUids.append(uid)
    }

    enum MockError: Error { case testError }
}
