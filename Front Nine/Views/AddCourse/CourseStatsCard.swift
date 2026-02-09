//
//  CourseStatsCard.swift
//  Front Nine
//

import SwiftUI

/// Reusable 4-column stats display showing PAR, RATING, SLOPE, and YARDS.
/// Used in both CourseDetailPreviewView (during add flow) and CourseDetailView.
struct CourseStatsCard: View {
    let par: Int?
    let courseRating: Double?
    let slope: Int?
    let totalYards: Int?
    var teeName: String?

    var body: some View {
        VStack(spacing: 12) {
            if let teeName {
                Text("\(teeName.uppercased()) TEES")
                    .font(FNFonts.label())
                    .foregroundStyle(FNColors.textLight)
                    .kerning(0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 0) {
                statColumn(label: "PAR", value: par.map { "\($0)" })
                statColumn(label: "RATING", value: courseRating.map { String(format: "%.1f", $0) })
                statColumn(label: "SLOPE", value: slope.map { "\($0)" })
                statColumn(label: "YARDS", value: totalYards.map { formatYardage($0) })
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
    }

    private func statColumn(label: String, value: String?) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(FNColors.textLight)
                .kerning(0.5)

            Text(value ?? "—")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(value != nil ? FNColors.text : FNColors.tan)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatYardage(_ yards: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: yards)) ?? "\(yards)"
    }
}
