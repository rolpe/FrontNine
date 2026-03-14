//
//  ProfilePhotoService.swift
//  Front Nine

import UIKit
import FirebaseStorage
import os

/// Handles profile photo upload, download, caching, and deletion via Firebase Storage.
/// Two-tier cache: in-memory dictionary (tracked by @Observable) + disk cache in Caches directory.
@MainActor @Observable
final class ProfilePhotoService {
    // Computed to avoid accessing Storage before FirebaseApp.configure()
    private var storage: Storage { Storage.storage() }
    private let logger = Logger(subsystem: "com.frontnine", category: "ProfilePhoto")

    /// In-memory image cache keyed by uid — tracked by @Observable for automatic view updates
    private var imageCache: [String: UIImage] = [:]

    /// UIDs currently being downloaded — prevents duplicate fetches
    private var downloading: Set<String> = []

    /// Currently uploading
    private(set) var isUploading = false

    /// Disk cache directory: Caches/profile_photos/
    private let diskCacheURL: URL? = {
        guard let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = caches.appendingPathComponent("profile_photos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

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

        // Cache the uploaded image in memory and on disk
        imageCache[uid] = image
        saveToDisk(data: data, uid: uid)

        return url.absoluteString
    }

    // MARK: - Download / Cache

    /// Get a cached image or trigger download from URL.
    /// Priority: in-memory → disk → network download.
    func image(for uid: String, url: String?) -> UIImage? {
        // 1. Check in-memory cache
        if let cached = imageCache[uid] {
            return cached
        }

        // 2. Check disk cache
        if let diskImage = loadFromDisk(uid: uid) {
            imageCache[uid] = diskImage
            return diskImage
        }

        // 3. Trigger async download if URL exists and not already downloading
        if let url, !downloading.contains(uid) {
            downloading.insert(uid)
            Task { await downloadAndCache(uid: uid, urlString: url) }
        }

        return nil
    }

    private func downloadAndCache(uid: String, urlString: String) async {
        defer { downloading.remove(uid) }

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                imageCache[uid] = image
                saveToDisk(data: data, uid: uid)
            }
        } catch {
            logger.error("Failed to download profile photo for \(uid): \(error.localizedDescription)")
        }
    }

    // MARK: - Disk Cache

    private func diskPath(for uid: String) -> URL? {
        diskCacheURL?.appendingPathComponent("\(uid).jpg")
    }

    private func saveToDisk(data: Data, uid: String) {
        guard let path = diskPath(for: uid) else { return }
        try? data.write(to: path, options: .atomic)
    }

    private func loadFromDisk(uid: String) -> UIImage? {
        guard let path = diskPath(for: uid),
              let data = try? Data(contentsOf: path),
              let image = UIImage(data: data) else { return nil }
        return image
    }

    private func removeFromDisk(uid: String) {
        guard let path = diskPath(for: uid) else { return }
        try? FileManager.default.removeItem(at: path)
    }

    // MARK: - Delete

    /// Delete the profile photo from Storage and clear both caches.
    func deletePhoto(uid: String) async throws {
        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        try await ref.delete()
        imageCache.removeValue(forKey: uid)
        removeFromDisk(uid: uid)
    }

    /// Clear a specific user's cached image from both caches (e.g. after URL change).
    func clearCache(for uid: String) {
        imageCache.removeValue(forKey: uid)
        removeFromDisk(uid: uid)
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
