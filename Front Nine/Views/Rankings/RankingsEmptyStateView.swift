//
//  RankingsEmptyStateView.swift
//  Front Nine
//

import SwiftUI

struct RankingsEmptyStateView: View {
    let onAddCourse: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "flag.fill")
                .font(.system(size: 48))
                .foregroundStyle(FNColors.sage)

            Text("No courses yet")
                .font(FNFonts.header())
                .foregroundStyle(FNColors.text)

            Text("Add your first course to start\nbuilding your rankings")
                .font(FNFonts.body())
                .foregroundStyle(FNColors.textLight)
                .multilineTextAlignment(.center)

            Button(action: onAddCourse) {
                Text("Add Course")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(FNColors.sage)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)

            Spacer()
        }
    }
}
