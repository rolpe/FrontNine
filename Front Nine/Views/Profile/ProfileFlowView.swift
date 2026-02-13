//
//  ProfileFlowView.swift
//  Front Nine
//

import SwiftUI

struct ProfileFlowView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch authService.authState {
            case .unknown, .signedOut:
                SignInView(onDismiss: { dismiss() })

            case .needsSetup:
                ProfileSetupView()

            case .signedIn:
                ProfileView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.authState)
    }
}
