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

    // Follow (atomic batch writes)
    func followUser(currentUid: String, targetUid: String) async throws
    func unfollowUser(currentUid: String, targetUid: String) async throws
    func checkFollowing(currentUid: String, targetUid: String) async throws -> Bool
    func fetchFollowingUids(uid: String) async throws -> [String]
    func fetchFollowerUids(uid: String) async throws -> [String]
    func fetchUserProfiles(uids: [String]) async throws -> [UserProfile]

    // User Search
    func searchUsers(query: String, limit: Int) async throws -> [UserProfile]
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

    // MARK: - Follow

    func followUser(currentUid: String, targetUid: String) async throws {
        let batch = db.batch()
        let timestamp = FieldValue.serverTimestamp()

        // Add to current user's following subcollection
        let followingRef = usersCollection.document(currentUid)
            .collection("following").document(targetUid)
        batch.setData(["followedAt": timestamp], forDocument: followingRef)

        // Add to target user's followers subcollection
        let followerRef = usersCollection.document(targetUid)
            .collection("followers").document(currentUid)
        batch.setData(["followedAt": timestamp], forDocument: followerRef)

        // Increment counts atomically
        batch.updateData(
            ["followingCount": FieldValue.increment(Int64(1))],
            forDocument: usersCollection.document(currentUid)
        )
        batch.updateData(
            ["followerCount": FieldValue.increment(Int64(1))],
            forDocument: usersCollection.document(targetUid)
        )

        try await batch.commit()
    }

    func unfollowUser(currentUid: String, targetUid: String) async throws {
        let batch = db.batch()

        // Remove from current user's following
        let followingRef = usersCollection.document(currentUid)
            .collection("following").document(targetUid)
        batch.deleteDocument(followingRef)

        // Remove from target user's followers
        let followerRef = usersCollection.document(targetUid)
            .collection("followers").document(currentUid)
        batch.deleteDocument(followerRef)

        // Decrement counts atomically
        batch.updateData(
            ["followingCount": FieldValue.increment(Int64(-1))],
            forDocument: usersCollection.document(currentUid)
        )
        batch.updateData(
            ["followerCount": FieldValue.increment(Int64(-1))],
            forDocument: usersCollection.document(targetUid)
        )

        try await batch.commit()
    }

    func checkFollowing(currentUid: String, targetUid: String) async throws -> Bool {
        let doc = try await usersCollection.document(currentUid)
            .collection("following").document(targetUid).getDocument()
        return doc.exists
    }

    func fetchFollowingUids(uid: String) async throws -> [String] {
        let snapshot = try await usersCollection.document(uid)
            .collection("following")
            .order(by: "followedAt", descending: true)
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }

    func fetchFollowerUids(uid: String) async throws -> [String] {
        let snapshot = try await usersCollection.document(uid)
            .collection("followers")
            .order(by: "followedAt", descending: true)
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }

    func fetchUserProfiles(uids: [String]) async throws -> [UserProfile] {
        guard !uids.isEmpty else { return [] }

        // Firestore 'in' queries limited to 30 items per query
        var profiles: [String: UserProfile] = [:]
        for chunk in uids.chunked(into: 30) {
            let snapshot = try await usersCollection
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            for doc in snapshot.documents {
                if let profile = parseProfile(from: doc.data(), uid: doc.documentID) {
                    profiles[doc.documentID] = profile
                }
            }
        }

        // Return in original UID order
        return uids.compactMap { profiles[$0] }
    }

    // MARK: - User Search

    func searchUsers(query: String, limit: Int) async throws -> [UserProfile] {
        let prefix = query.lowercased()
        let end = prefix + "\u{f8ff}"

        // Run handle and name queries in parallel, merge results
        async let handleSnapshot = usersCollection
            .whereField("handle", isGreaterThanOrEqualTo: prefix)
            .whereField("handle", isLessThan: end)
            .limit(to: limit)
            .getDocuments()

        async let nameSnapshot = usersCollection
            .whereField("displayNameLower", isGreaterThanOrEqualTo: prefix)
            .whereField("displayNameLower", isLessThan: end)
            .limit(to: limit)
            .getDocuments()

        let (handleResults, nameResults) = try await (handleSnapshot, nameSnapshot)

        // Merge and deduplicate, preserving handle matches first
        var seen = Set<String>()
        var profiles: [UserProfile] = []

        for doc in handleResults.documents {
            if let profile = parseProfile(from: doc.data(), uid: doc.documentID) {
                seen.insert(doc.documentID)
                profiles.append(profile)
            }
        }
        for doc in nameResults.documents {
            if !seen.contains(doc.documentID),
               let profile = parseProfile(from: doc.data(), uid: doc.documentID) {
                profiles.append(profile)
            }
        }

        return Array(profiles.prefix(limit))
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
