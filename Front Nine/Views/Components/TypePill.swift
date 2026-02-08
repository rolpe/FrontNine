//
//  TypePill.swift
//  Front Nine

import SwiftUI

struct TypePill: View {
    let courseType: CourseType

    var body: some View {
        Text(courseType.rawValue.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(FNColors.sage)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(FNColors.sage.opacity(0.15))
            .clipShape(Capsule())
    }
}
