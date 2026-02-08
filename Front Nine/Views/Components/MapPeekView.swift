//
//  MapPeekView.swift
//  Front Nine
//

import SwiftUI
import MapKit

/// A non-interactive map peek with gradient fade and optional Directions button.
/// Used at the top of course detail screens for visual context.
struct MapPeekView: View {
    let coordinate: CLLocationCoordinate2D
    let courseName: String
    var height: CGFloat = 170
    var showDirectionsButton: Bool = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1500,
                longitudinalMeters: 1500
            )), interactionModes: []) {
                Marker(courseName, coordinate: coordinate)
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
                .frame(height: 60)
            }

            if showDirectionsButton {
                Button(action: openDirections) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 11))
                        Text("Directions")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundStyle(FNColors.textLight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.trailing, 12)
                .padding(.top, 12)
            }
        }
    }

    private func openDirections() {
        let mapItem: MKMapItem
        if #available(iOS 26, *) {
            mapItem = MKMapItem(
                location: CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ),
                address: nil
            )
        } else {
            mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        }
        mapItem.name = courseName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
