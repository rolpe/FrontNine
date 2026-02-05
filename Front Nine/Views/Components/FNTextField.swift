//
//  FNTextField.swift
//  Front Nine
//

import SwiftUI

struct FNTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var characterLimit: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            TextField(placeholder, text: $text)
                .font(FNFonts.body())
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FNColors.tan, lineWidth: 1.5)
                )
                .onChange(of: text) { _, newValue in
                    if let limit = characterLimit, newValue.count > limit {
                        text = String(newValue.prefix(limit))
                    }
                }
        }
    }
}
