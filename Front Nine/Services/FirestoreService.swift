//
//  FirestoreService.swift
//  Front Nine
//

import Foundation
import FirebaseFirestore

// Protocol for testability (mock injection in tests)
@MainActor
protocol FirestoreServiceProtocol {
    // Profile
    func fetchUserProfile(uid: String) async throws -> UserProfile?
    func saveUserProfile(_ profile: UserProfile) async throws
    func updateProfileField(uid: String, field: String, value: Any) async throws
    func isHandleAvailable(_ handle: String, excludingUID uid: String?) async throws -> Bool
    func deleteUserProfile(uid: String) async throws

    // Rankings
    func saveRanking(_ ranking: FirestoreRanking, courseId: String, uid: String) async throws
    func deleteRanking(courseId: String, uid: String) async throws
    func batchSaveRankings(_ rankings: [(courseId: String, data: [String: Any])], uid: String) async throws
    func fetchRankings(uid: String) async throws -> [FirestoreRanking]
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

    func updateProfileField(uid: String, field: String, value: Any) async throws {
        try await usersCollection.document(uid).updateData([field: value])
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

    // MARK: - Rankings

    private func rankingsCollection(uid: String) -> CollectionReference {
        usersCollection.document(uid).collection("rankings")
    }

    func saveRanking(_ ranking: FirestoreRanking, courseId: String, uid: String) async throws {
        try await rankingsCollection(uid: uid).document(courseId).setData(ranking.firestoreData())
    }

    func deleteRanking(courseId: String, uid: String) async throws {
        try await rankingsCollection(uid: uid).document(courseId).delete()
    }

    func batchSaveRankings(_ rankings: [(courseId: String, data: [String: Any])], uid: String) async throws {
        let batch = db.batch()
        let collection = rankingsCollection(uid: uid)
        for (courseId, data) in rankings {
            batch.setData(data, forDocument: collection.document(courseId))
        }
        try await batch.commit()
    }

    func fetchRankings(uid: String) async throws -> [FirestoreRanking] {
        let snapshot = try await rankingsCollection(uid: uid)
            .order(by: "rankPosition")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            parseRanking(from: doc.data())
        }
    }

    private func parseRanking(from data: [String: Any]) -> FirestoreRanking? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let city = data["city"] as? String,
              let state = data["state"] as? String,
              let courseType = data["courseType"] as? String,
              let holeCount = data["holeCount"] as? Int,
              let rating = data["rating"] as? String,
              let rankPosition = data["rankPosition"] as? Int else { return nil }

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()

        return FirestoreRanking(
            id: id,
            name: name,
            city: city,
            state: state,
            country: data["country"] as? String,
            courseType: courseType,
            holeCount: holeCount,
            rating: rating,
            rankPosition: rankPosition,
            notes: data["notes"] as? String,
            par: data["par"] as? Int,
            courseRating: data["courseRating"] as? Double,
            slope: data["slope"] as? Int,
            totalYards: data["totalYards"] as? Int,
            golfCourseApiId: data["golfCourseApiId"] as? Int,
            teeName: data["teeName"] as? String,
            latitude: data["latitude"] as? Double,
            longitude: data["longitude"] as? Double,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
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
            isPublic: data["isPublic"] as? Bool ?? true,
            followerCount: data["followerCount"] as? Int ?? 0,
            followingCount: data["followingCount"] as? Int ?? 0,
            rankingCount: data["rankingCount"] as? Int ?? 0,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
