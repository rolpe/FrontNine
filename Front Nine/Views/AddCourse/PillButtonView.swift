//
//  PillButtonView.swift
//  Front Nine
//

import SwiftUI

struct PillButtonView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? .white : FNColors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? FNColors.sage : .white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? FNColors.sage : FNColors.tan, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
