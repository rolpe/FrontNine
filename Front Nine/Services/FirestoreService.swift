//
//  FirestoreService.swift
//  Front Nine
//

import Foundation
import FirebaseFirestore

// Protocol for testability (mock injection in tests)
@MainActor
protocol FirestoreServiceProtocol {
    func fetchUserProfile(uid: String) async throws -> UserProfile?
    func saveUserProfile(_ profile: UserProfile) async throws
    func isHandleAvailable(_ handle: String, excludingUID uid: String?) async throws -> Bool
    func deleteUserProfile(uid: String) async throws
}

@MainActor
final class FirestoreService: FirestoreServiceProtocol {
    // Computed to avoid accessing Firestore before FirebaseApp.configure()
    private var db: Firestore { Firestore.firestore() }

    private var usersCollection: CollectionReference {
        db.collection("users")
    }

    func fetchUserProfile(uid: String) async throws -> UserProfile? {
        let document = try await usersCollection.document(uid).getDocument()
        guard document.exists, let data = document.data() else { return nil }
        return parseProfile(from: data, uid: uid)
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        try await usersCollection.document(profile.uid).setData(profile.firestoreData())
    }

    func isHandleAvailable(_ handle: String, excludingUID uid: String? = nil) async throws -> Bool {
        let snapshot = try await usersCollection
            .whereField("handle", isEqualTo: handle)
            .limit(to: 1)
            .getDocuments()

        if let uid, let doc = snapshot.documents.first {
            // If the only match is the current user, handle is "available" (they already own it)
            return doc.documentID == uid
        }
        return snapshot.documents.isEmpty
    }

    func deleteUserProfile(uid: String) async throws {
        try await usersCollection.document(uid).delete()
    }

    // MARK: - Parsing

    private func parseProfile(from data: [String: Any], uid: String) -> UserProfile? {
        guard let displayName = data["displayName"] as? String,
              let handle = data["handle"] as? String else { return nil }

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()

        return UserProfile(
            uid: uid,
            displayName: displayName,
            handle: handle,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
