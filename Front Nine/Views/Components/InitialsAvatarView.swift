//
//  InitialsAvatarView.swift
//  Front Nine

import SwiftUI

struct InitialsAvatarView: View {
    let name: String
    var size: CGFloat = 80

    var body: some View {
        Circle()
            .fill(FNColors.sage.opacity(0.15))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.35, weight: .medium, design: .serif))
                    .foregroundStyle(FNColors.sage)
            )
    }

    private var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        return (first + last).uppercased()
    }
}
