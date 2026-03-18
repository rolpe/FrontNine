//
//  ShareImageSheet.swift
//  Front Nine

import LinkPresentation
import SwiftUI

/// Wraps UIActivityViewController to share a rankings image with a rich preview.
struct ShareImageSheet: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let itemSource = RankingsImageItemSource(image: image)
        let controller = UIActivityViewController(
            activityItems: [itemSource],
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Provides LPLinkMetadata so the share sheet shows a rich preview with the image.
final class RankingsImageItemSource: NSObject, UIActivityItemSource {
    let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        image
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "My Golf Course Rankings"
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}
