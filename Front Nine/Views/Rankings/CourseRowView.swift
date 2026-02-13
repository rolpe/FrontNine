//
//  CourseRowView.swift
//  Front Nine
//

import SwiftUI

struct CourseRowView: View {
    let course: Course
    var onDelete: ((Course) -> Void)? = nil

    @State private var showingDeleteConfirmation = false

    private var isHero: Bool { course.rankPosition == 1 }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Rank number with optional crown
            VStack(spacing: 2) {
                if isHero {
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 6)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 4)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(FNColors.tan)
                            .frame(width: 2, height: 6)
                    }
                }

                Text("\(course.rankPosition)")
                    .font(isHero ? FNFonts.heroRankNumber() : FNFonts.rankNumber())
                    .foregroundStyle(isHero ? course.rating.tierColor : FNColors.tan)
            }
            .frame(width: 44, alignment: isHero ? .center : .leading)

            // Accent bar with gradient fade
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [course.rating.tierColor, course.rating.tierColor.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: isHero ? 48 : 36)
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(isHero ? .system(size: 16, weight: .semibold) : FNFonts.bodyMedium())
                    .foregroundStyle(FNColors.text)

                HStack(spacing: 6) {
                    Text(course.locationText)
                        .font(FNFonts.subtext())
                        .foregroundStyle(FNColors.textLight)

                    TypePill(courseType: course.courseType)
                    HolesPill(holeCount: course.holeCount)
                }
            }

            Spacer()
        }
        .padding(.vertical, isHero ? 18 : 16)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        .confirmationDialog(
            "Delete \(course.name)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete?(course)
            }
        } message: {
            Text("This will remove the course from your rankings.")
        }
    }
}
