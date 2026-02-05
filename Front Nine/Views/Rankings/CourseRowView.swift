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

                Text("\(course.city), \(course.state)")
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
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
