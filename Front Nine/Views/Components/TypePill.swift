//
//  TypePill.swift
//  Front Nine

import SwiftUI

struct TypePill: View {
    let courseType: CourseType

    var body: some View {
        InfoPill(courseType.rawValue.uppercased())
    }
}

struct HolesPill: View {
    let holeCount: Int

    var body: some View {
        if holeCount != 18 {
            InfoPill("\(holeCount) HOLES")
        }
    }
}

struct InfoPill: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(FNColors.sage)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(FNColors.sage.opacity(0.15))
            .clipShape(Capsule())
    }
}
