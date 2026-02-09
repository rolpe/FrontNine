//
//  CourseRowView.swift
//  Front Nine
//

import SwiftUI

struct CourseRowView: View {
    let course: Course
    var onDelete: ((Course) -> Void)? = nil

    @State private var showingDeleteConfirmation = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text("\(course.rankPosition)")
                .font(FNFonts.rankNumber())
                .foregroundStyle(FNColors.tan)
                .frame(width: 44, alignment: .leading)

            RoundedRectangle(cornerRadius: 2)
                .fill(course.rating.tierColor)
                .frame(width: 3, height: 36)
                .padding(.trailing, 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(FNFonts.bodyMedium())
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
        .padding(.vertical, 16)
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
