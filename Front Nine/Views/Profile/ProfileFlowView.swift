//
//  ProfileFlowView.swift
//  Front Nine
//

import SwiftUI

enum ProfileDestination: Hashable {
    case findMembers
    case following(uid: String)
    case followers(uid: String)
}

struct ProfileFlowView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss

    var showDismiss: Bool = true
    @Binding var navigationPath: NavigationPath

    init(showDismiss: Bool = true, navigationPath: Binding<NavigationPath>? = nil) {
        self.showDismiss = showDismiss
        self._navigationPath = navigationPath ?? .constant(NavigationPath())
    }

    var body: some View {
        Group {
            switch authService.authState {
            case .unknown, .signedOut:
                SignInView(
                    onDismiss: { if showDismiss { dismiss() } },
                    showSkipButton: showDismiss
                )

            case .needsSetup:
                ProfileSetupView()

            case .signedIn:
                NavigationStack(path: $navigationPath) {
                    ProfileView(showDismissButton: showDismiss)
                        .navigationDestination(for: UserProfile.self) { profile in
                            OtherUserProfileView(profile: profile)
                        }
                        .navigationDestination(for: ProfileDestination.self) { destination in
                            switch destination {
                            case .findMembers:
                                UserSearchView()
                            case .following(let uid):
                                FollowListView(mode: .following, uid: uid)
                            case .followers(let uid):
                                FollowListView(mode: .followers, uid: uid)
                            }
                        }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.authState)
    }
}
