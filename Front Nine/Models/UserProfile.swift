//
//  UserProfile.swift
//  Front Nine
//

import Foundation

struct UserProfile: Codable, Equatable {
    let uid: String
    var displayName: String
    var handle: String
    var createdAt: Date
    var updatedAt: Date

    func firestoreData() -> [String: Any] {
        [
            "uid": uid,
            "displayName": displayName,
            "handle": handle,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
}
