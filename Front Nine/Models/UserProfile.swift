//
//  UserProfile.swift
//  Front Nine
//

import Foundation

struct UserProfile: Codable, Equatable, Hashable {
    let uid: String
    var displayName: String
    var handle: String
    var isPublic: Bool
    var followerCount: Int
    var followingCount: Int
    var rankingCount: Int
    var photoURL: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        uid: String,
        displayName: String,
        handle: String,
        isPublic: Bool = true,
        followerCount: Int = 0,
        followingCount: Int = 0,
        rankingCount: Int = 0,
        photoURL: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.uid = uid
        self.displayName = displayName
        self.handle = handle
        self.isPublic = isPublic
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.rankingCount = rankingCount
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func firestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "uid": uid,
            "displayName": displayName,
            "displayNameLower": displayName.lowercased(),
            "handle": handle,
            "isPublic": isPublic,
            "followerCount": followerCount,
            "followingCount": followingCount,
            "rankingCount": rankingCount,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
        if let photoURL { data["photoURL"] = photoURL }
        return data
    }
}
