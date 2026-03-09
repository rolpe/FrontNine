//
//  ProfileAvatarView.swift
//  Front Nine

import SwiftUI

/// Displays a profile photo when available, falling back to initials.
/// Reads from ProfilePhotoService's in-memory cache for instant display.
struct ProfileAvatarView: View {
    @Environment(ProfilePhotoService.self) private var photoService

    let name: String
    let photoURL: String?
    let uid: String
    var size: CGFloat = 80

    var body: some View {
        Group {
            if let image = photoService.image(for: uid, url: photoURL) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                InitialsAvatarView(name: name, size: size)
            }
        }
    }
}
