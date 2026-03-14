//
//  RankingSyncService.swift
//  Front Nine
//

import Foundation
import os

/// Pushes local rankings to Firestore for social visibility.
/// One-way sync: SwiftData is source of truth.
/// Fire-and-forget with error logging — never blocks the UI.
@MainActor @Observable
final class RankingSyncService {
    private let firestoreService: any FirestoreServiceProtocol
    private let logger = Logger(subsystem: "com.frontnine", category: "RankingSync")

    init(firestoreService: (any FirestoreServiceProtocol)? = nil) {
        self.firestoreService = firestoreService ?? FirestoreService()
    }

    // MARK: - Single Course

    /// Sync a single course to Firestore.
    func syncCourse(_ course: Course, uid: String) {
        let ranking = FirestoreRanking(from: course)
        let courseId = course.id.uuidString
        Task {
            do {
                try await firestoreService.saveRanking(ranking, courseId: courseId, uid: uid)
            } catch {
                logger.error("Failed to sync course \(courseId): \(error.localizedDescription)")
            }
        }
    }

    /// Delete a course from Firestore.
    func deleteCourseFromCloud(courseId: String, uid: String) {
        Task {
            do {
                try await firestoreService.deleteRanking(courseId: courseId, uid: uid)
            } catch {
                logger.error("Failed to delete course \(courseId) from cloud: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Multiple Courses (Batch)

    /// Sync multiple courses whose ranks changed (e.g., after insert/rerank/delete).
    func syncMultipleCourses(_ courses: [Course], uid: String) {
        guard !courses.isEmpty else { return }
        let updates = courses.map { course in
            (courseId: course.id.uuidString, data: FirestoreRanking(from: course).firestoreData())
        }
        Task {
            do {
                try await firestoreService.batchSaveRankings(updates, uid: uid)
            } catch {
                logger.error("Failed to batch sync \(courses.count) courses: \(error.localizedDescription)")
            }
        }
    }

    /// Sync courses that were affected by a rank change.
    /// Syncs the primary course plus any courses whose rankPosition was shifted.
    func syncAfterRankChange(allCourses: [Course], changedIds: Set<UUID>, uid: String) {
        let affected = allCourses.filter { changedIds.contains($0.id) }
        syncMultipleCourses(affected, uid: uid)
    }

    // MARK: - Ranking Count

    /// Update the rankingCount field on the user's profile.
    func updateRankingCount(_ count: Int, uid: String) {
        Task {
            do {
                try await firestoreService.updateProfileField(uid: uid, field: "rankingCount", value: count)
            } catch {
                logger.error("Failed to update ranking count: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Activity

    /// Write an activity event to Firestore. Fire-and-forget.
    func writeActivity(
        type: ActivityType,
        course: Course,
        newRank: Int,
        oldRank: Int?,
        actorProfile: UserProfile,
        uid: String,
        allCourses: [Course]
    ) {
        // Compute tier position for sentiment descriptor
        let sameTier = allCourses.filter { $0.rating == course.rating }
            .sorted { $0.rankPosition < $1.rankPosition }
        let tierRank = (sameTier.firstIndex(where: { $0.id == course.id }) ?? 0) + 1
        let tierCount = sameTier.count

        let item = ActivityItem(
            id: UUID().uuidString,
            type: type,
            actorUid: actorProfile.uid,
            actorDisplayName: actorProfile.displayName,
            actorHandle: actorProfile.handle,
            courseName: course.name,
            courseCity: course.city,
            courseState: course.state,
            courseCountry: course.country,
            courseRating: course.rating.rawValue,
            newRankPosition: newRank,
            oldRankPosition: oldRank,
            courseLatitude: course.latitude,
            courseLongitude: course.longitude,
            courseType: course.courseType.rawValue,
            courseHoleCount: course.holeCount,
            tierRank: tierRank,
            tierCount: tierCount,
            timestamp: Date()
        )
        Task {
            do {
                try await firestoreService.saveActivity(item.firestoreData(), uid: uid)
            } catch {
                logger.error("Failed to write activity: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Full Sync

    /// Upload all local rankings to Firestore. Used for initial sync when a user first signs in
    /// or to re-sync all data.
    func fullSync(courses: [Course], uid: String) {
        guard !courses.isEmpty else { return }

        // Firestore batch writes limited to 500 per batch
        let chunks = courses.chunked(into: 500)
        Task {
            do {
                for chunk in chunks {
                    let updates = chunk.map { course in
                        (courseId: course.id.uuidString, data: FirestoreRanking(from: course).firestoreData())
                    }
                    try await firestoreService.batchSaveRankings(updates, uid: uid)
                }
                try await firestoreService.updateProfileField(uid: uid, field: "rankingCount", value: courses.count)
                logger.info("Full sync completed: \(courses.count) courses")
            } catch {
                logger.error("Full sync failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Array Chunking

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
