//
//  ComparisonMapView.swift
//  Front Nine
//

import SwiftUI
import MapKit

/// A non-interactive map showing two course pins, used at the top of the comparison screen.
/// Automatically fits the region to show both markers with padding.
struct ComparisonMapView: View {
    let coordinateA: CLLocationCoordinate2D
    let coordinateB: CLLocationCoordinate2D
    let nameA: String
    let nameB: String
    var height: CGFloat = 200

    var body: some View {
        Map(initialPosition: .region(regionForBothPins), interactionModes: []) {
            Marker(nameA, coordinate: coordinateA)
                .tint(FNColors.sage)
            Marker(nameB, coordinate: coordinateB)
                .tint(FNColors.sage)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: height)
        .opacity(0.7)
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [FNColors.cream, FNColors.cream.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 50)
        }
    }

    private var regionForBothPins: MKCoordinateRegion {
        let minLat = min(coordinateA.latitude, coordinateB.latitude)
        let maxLat = max(coordinateA.latitude, coordinateB.latitude)
        let minLon = min(coordinateA.longitude, coordinateB.longitude)
        let maxLon = max(coordinateA.longitude, coordinateB.longitude)

        let latSpan = maxLat - minLat
        let lonSpan = maxLon - minLon

        // Shift center slightly south — markers extend upward from their
        // coordinate, so the top pin needs extra headroom.
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2 - latSpan * 0.05,
            longitude: (minLon + maxLon) / 2
        )

        // Double the span for generous padding around both pins
        let latDelta = max(latSpan * 2.0, 1.0)
        let lonDelta = max(lonSpan * 2.0, 1.0)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}
