//
//  AuthService.swift
//  Front Nine
//

import Foundation
import FirebaseAuth

enum AuthState: Equatable {
    case unknown    // App just launched, haven't checked yet
    case signedOut  // No Firebase user
    case signedIn   // Firebase user + Firestore profile loaded
    case needsSetup // Firebase user exists but no Firestore profile yet
}

@MainActor @Observable
final class AuthService {
    var authState: AuthState = .unknown
    var userProfile: UserProfile?

    private(set) var currentUser: User?
    private var authListener: AuthStateDidChangeListenerHandle?
    private let firestoreService: any FirestoreServiceProtocol

    var isSignedIn: Bool { authState == .signedIn }

    /// Display name from Firebase Auth user (available after sign-in, before profile setup)
    var currentUserDisplayName: String? { currentUser?.displayName }

    init(firestoreService: (any FirestoreServiceProtocol)? = nil) {
        self.firestoreService = firestoreService ?? FirestoreService()
    }

    // MARK: - Auth State Listener

    func startListening() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.currentUser = user
                if let user {
                    await self.loadProfile(for: user.uid)
                } else {
                    self.userProfile = nil
                    self.authState = .signedOut
                }
            }
        }
    }

    // MARK: - Sign In with Apple

    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: fullName
        )
        try await Auth.auth().signIn(with: credential)
        // Auth state listener will fire and call loadProfile
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
        // Auth state listener will fire and reset state
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        guard let user = currentUser else { return }

        // Delete Firestore profile first
        try await firestoreService.deleteUserProfile(uid: user.uid)

        // Then delete Firebase Auth user
        try await user.delete()
        // Auth state listener will fire and reset state
    }

    // MARK: - Profile Management

    func saveProfile(displayName: String, handle: String) async throws {
        guard let user = currentUser else { return }

        let now = Date()
        let profile = UserProfile(
            uid: user.uid,
            displayName: displayName,
            handle: handle,
            createdAt: userProfile?.createdAt ?? now,
            updatedAt: now
        )

        try await firestoreService.saveUserProfile(profile)
        self.userProfile = profile
        self.authState = .signedIn
    }

    func togglePrivacy() async throws {
        guard let uid = currentUser?.uid, var profile = userProfile else { return }
        let newValue = !profile.isPublic
        try await firestoreService.updateProfileField(uid: uid, field: "isPublic", value: newValue)
        profile.isPublic = newValue
        self.userProfile = profile
    }

    func checkHandleAvailability(_ handle: String) async -> Bool {
        do {
            return try await firestoreService.isHandleAvailable(handle, excludingUID: currentUser?.uid)
        } catch {
            return false
        }
    }

    /// Re-fetch the current user's profile from Firestore to pick up external changes (e.g. follower count).
    func refreshProfile() async {
        guard let uid = currentUser?.uid else { return }
        await loadProfile(for: uid)
    }

    // MARK: - Private

    private func loadProfile(for uid: String) async {
        do {
            if let profile = try await firestoreService.fetchUserProfile(uid: uid) {
                self.userProfile = profile
                self.authState = .signedIn
            } else {
                self.authState = .needsSetup
            }
        } catch {
            // If we can't load profile, treat as needs setup
            self.authState = .needsSetup
        }
    }
}
