//
//  SignInView.swift
//  Front Nine
//

import SwiftUI

struct SignInView: View {
    let onDismiss: () -> Void
    var showSkipButton: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Branding
            VStack(spacing: 12) {
                FlagIcon(variant: .filled, color: FNColors.sage, size: 48)

                Text("Front Nine")
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(FNColors.text)

                Text("Sign in to set up your profile\nand connect with other members.")
                    .font(FNFonts.subtext())
                    .foregroundStyle(FNColors.textLight)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Sign in button + skip
            VStack(spacing: 16) {
                AppleSignInButton()
                    .padding(.horizontal, 20)

                if showSkipButton {
                    Button {
                        onDismiss()
                    } label: {
                        Text("Continue without signing in")
                            .font(.system(size: 15))
                            .foregroundStyle(FNColors.textLight)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
    }
}
