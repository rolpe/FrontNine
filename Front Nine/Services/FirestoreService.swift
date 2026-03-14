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

    // Activity
    func saveActivity(_ data: [String: Any], uid: String) async throws
    func fetchActivity(uid: String, limit: Int) async throws -> [ActivityItem]
    func deleteAllActivity(uid: String) async throws
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

        // Use document ID as the ranking id to guarantee uniqueness,
        // and deduplicate by course name+city in case of stale documents
        var seen = Set<String>()
        return snapshot.documents.compactMap { doc in
            guard var ranking = parseRanking(from: doc.data()) else { return nil }
            ranking.id = doc.documentID
            let key = "\(ranking.name.lowercased())|\(ranking.city.lowercased())|\(ranking.state.lowercased())"
            guard seen.insert(key).inserted else { return nil }
            return ranking
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

        let normalizedRating = Self.normalizeRating(rating)

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
            rating: normalizedRating,
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

    // MARK: - Activity

    private func activityCollection(uid: String) -> CollectionReference {
        usersCollection.document(uid).collection("activity")
    }

    func saveActivity(_ data: [String: Any], uid: String) async throws {
        try await activityCollection(uid: uid).addDocument(data: data)
    }

    func fetchActivity(uid: String, limit: Int) async throws -> [ActivityItem] {
        let snapshot = try await activityCollection(uid: uid)
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            parseActivity(from: doc.data(), id: doc.documentID)
        }
    }

    private func parseActivity(from data: [String: Any], id: String) -> ActivityItem? {
        guard let typeRaw = data["type"] as? String,
              let type = ActivityType(rawValue: typeRaw),
              let actorUid = data["actorUid"] as? String,
              let actorDisplayName = data["actorDisplayName"] as? String,
              let actorHandle = data["actorHandle"] as? String,
              let courseName = data["courseName"] as? String,
              let courseCity = data["courseCity"] as? String,
              let courseState = data["courseState"] as? String,
              let courseRating = data["courseRating"] as? String,
              let newRankPosition = data["newRankPosition"] as? Int else { return nil }

        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

        return ActivityItem(
            id: id,
            type: type,
            actorUid: actorUid,
            actorDisplayName: actorDisplayName,
            actorHandle: actorHandle,
            courseName: courseName,
            courseCity: courseCity,
            courseState: courseState,
            courseCountry: data["courseCountry"] as? String,
            courseRating: Self.normalizeRating(courseRating),
            newRankPosition: newRankPosition,
            oldRankPosition: data["oldRankPosition"] as? Int,
            courseLatitude: data["courseLatitude"] as? Double,
            courseLongitude: data["courseLongitude"] as? Double,
            courseType: data["courseType"] as? String,
            courseHoleCount: data["courseHoleCount"] as? Int,
            tierRank: data["tierRank"] as? Int,
            tierCount: data["tierCount"] as? Int,
            timestamp: timestamp
        )
    }

    func deleteAllActivity(uid: String) async throws {
        let snapshot = try await activityCollection(uid: uid).getDocuments()
        let batch = db.batch()
        for doc in snapshot.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
    }

    // MARK: - Helpers

    /// Normalize legacy "Didn't Love" rating strings to "Didn't Like"
    private static func normalizeRating(_ rating: String) -> String {
        rating == "Didn't Love" ? "Didn't Like" : rating
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
            photoURL: data["photoURL"] as? String,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
