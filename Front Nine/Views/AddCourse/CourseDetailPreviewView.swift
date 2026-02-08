//
//  CourseDetailPreviewView.swift
//  Front Nine
//

import SwiftUI
import MapKit

struct CourseDetailPreviewView: View {
    let result: CourseSearchResult
    var existingCourse: Course?
    var onBack: () -> Void
    var onAddAndRate: (CourseEnrichmentData?) -> Void

    @State private var enrichment = CourseEnrichmentService()

    private var isRerank: Bool { existingCourse != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Map peek at top with back button overlay
            ZStack(alignment: .topLeading) {
                MapPeekView(
                    coordinate: result.coordinate,
                    courseName: result.name
                )

                // Back button overlaid on map
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Search")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(FNColors.sage)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.leading, 12)
                .padding(.top, 12)
            }

            // Course name
            Text(result.name)
                .font(FNFonts.header())
                .foregroundStyle(FNColors.text)
                .tracking(-0.5)
                .lineSpacing(2)
                .padding(.horizontal, 20)

            // Location
            HStack(spacing: 5) {
                Image(systemName: "mappin")
                    .font(.system(size: 12))

                Text(locationText)
                    .font(.system(size: 15))
            }
            .foregroundStyle(FNColors.textLight)
            .padding(.horizontal, 20)
            .padding(.top, 6)

            // Already ranked indicator
            if let course = existingCourse {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(FNColors.sage)

                    Text("Currently ranked #\(course.rankPosition) \u{2022} \(course.rating.label)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(FNColors.sage)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            // Enrichment section
            VStack(alignment: .leading, spacing: 16) {
                if enrichment.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(FNColors.warmGray)
                        Text("Looking up course details...")
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.textLight)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else if let candidates = enrichment.matchCandidates {
                    CourseDisambiguationView(candidates: candidates) { course in
                        enrichment.selectCourse(course)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .transition(.opacity)
                } else if enrichment.matchedCourse != nil {
                    enrichedDataSection
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: enrichment.isLoading)
            .animation(.easeInOut(duration: 0.3), value: enrichment.matchedCourse?.id)

            // Divider
            Rectangle()
                .fill(FNColors.tan.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 20)
                .padding(.vertical, 24)

            // Action button
            Button(action: { onAddAndRate(enrichment.enrichmentData) }) {
                Text(isRerank ? "Re-rank This Course" : "Add & Rate This Course")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isRerank ? FNColors.tan : FNColors.sage)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
        .task {
            await enrichment.enrich(searchResult: result)
        }
    }

    @ViewBuilder
    private var enrichedDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if enrichment.availableTeeBoxes.count > 1 {
                TeePickerView(
                    teeBoxes: enrichment.availableTeeBoxes,
                    selectedTee: enrichment.selectedTeeBox,
                    onSelect: { enrichment.selectTeeBox($0) }
                )
            }

            if let data = enrichment.enrichmentData {
                CourseStatsCard(
                    par: data.par,
                    courseRating: data.courseRating,
                    slope: data.slope,
                    totalYards: data.totalYards,
                    teeName: enrichment.availableTeeBoxes.count <= 1 ? data.teeName : nil
                )
            }
        }
    }

    private var locationText: String {
        Course.formatLocation(city: result.city, state: result.state, country: result.country)
    }
}
