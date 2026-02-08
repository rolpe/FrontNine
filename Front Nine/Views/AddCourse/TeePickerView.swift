//
//  TeePickerView.swift
//  Front Nine
//

import SwiftUI

/// Horizontal scrollable tee selector using capsule pills.
struct TeePickerView: View {
    let teeBoxes: [GolfCourseAPITeeBox]
    let selectedTee: GolfCourseAPITeeBox?
    var onSelect: (GolfCourseAPITeeBox) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TEE BOX")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(teeBoxes) { tee in
                        PillButtonView(
                            title: tee.teeName,
                            isSelected: selectedTee?.teeName == tee.teeName,
                            action: { onSelect(tee) }
                        )
                    }
                }
            }
        }
    }
}
