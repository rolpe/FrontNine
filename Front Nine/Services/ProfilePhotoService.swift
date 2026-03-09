//
//  ProfilePhotoService.swift
//  Front Nine

import UIKit
import FirebaseStorage
import os

/// Handles profile photo upload, download, caching, and deletion via Firebase Storage.
@MainActor @Observable
final class ProfilePhotoService {
    // Computed to avoid accessing Storage before FirebaseApp.configure()
    private var storage: Storage { Storage.storage() }
    private let logger = Logger(subsystem: "com.frontnine", category: "ProfilePhoto")

    /// In-memory image cache keyed by uid
    private var imageCache = NSCache<NSString, UIImage>()

    /// Currently uploading
    private(set) var isUploading = false

    // MARK: - Upload

    /// Compress, upload, and return the download URL for a profile photo.
    func uploadPhoto(_ image: UIImage, uid: String) async throws -> String {
        guard let data = image.compressed(maxDimension: 300, quality: 0.8) else {
            throw ProfilePhotoError.compressionFailed
        }

        isUploading = true
        defer { isUploading = false }

        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()

        // Cache the uploaded image immediately
        imageCache.setObject(image, forKey: uid as NSString)

        return url.absoluteString
    }

    // MARK: - Download / Cache

    /// Get a cached image or download from URL.
    func image(for uid: String, url: String?) -> UIImage? {
        // Check cache first
        if let cached = imageCache.object(forKey: uid as NSString) {
            return cached
        }

        // Trigger async download if URL exists
        if let url {
            Task { await downloadAndCache(uid: uid, urlString: url) }
        }

        return nil
    }

    private func downloadAndCache(uid: String, urlString: String) async {
        // Double-check cache (another call may have populated it)
        if imageCache.object(forKey: uid as NSString) != nil { return }

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                imageCache.setObject(image, forKey: uid as NSString)
            }
        } catch {
            logger.error("Failed to download profile photo for \(uid): \(error.localizedDescription)")
        }
    }

    // MARK: - Delete

    /// Delete the profile photo from Storage and clear cache.
    func deletePhoto(uid: String) async throws {
        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        try await ref.delete()
        imageCache.removeObject(forKey: uid as NSString)
    }

    /// Clear a specific user's cached image (e.g. after URL change).
    func clearCache(for uid: String) {
        imageCache.removeObject(forKey: uid as NSString)
    }
}

// MARK: - Image Compression

private extension UIImage {
    /// Resize to fit within maxDimension and compress as JPEG.
    func compressed(maxDimension: CGFloat, quality: CGFloat) -> Data? {
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}

enum ProfilePhotoError: LocalizedError {
    case compressionFailed

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Failed to compress image"
        }
    }
}
