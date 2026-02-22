//
//  SignInView.swift
//  Front Nine
//

import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct SignInView: View {
    @Environment(AuthService.self) private var authService
    let onDismiss: () -> Void

    @State private var currentNonce: String?
    @State private var errorMessage: String?
    @State private var isSigningIn = false

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

            // Sign in button + error
            VStack(spacing: 16) {
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(FNColors.coral)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }

                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    handleSignInResult(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .disabled(isSigningIn)
                .opacity(isSigningIn ? 0.6 : 1)

                Button {
                    onDismiss()
                } label: {
                    Text("Continue without signing in")
                        .font(.system(size: 15))
                        .foregroundStyle(FNColors.textLight)
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FNColors.cream)
    }

    // MARK: - Sign in with Apple handling

    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = appleCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = currentNonce else {
                errorMessage = "Could not process Apple sign-in credentials."
                return
            }

            let fullName = appleCredential.fullName
            isSigningIn = true
            errorMessage = nil

            Task {
                do {
                    try await authService.signInWithApple(
                        idToken: tokenString,
                        nonce: nonce,
                        fullName: fullName
                    )
                } catch {
                    errorMessage = "Sign-in failed. Please try again."
                    isSigningIn = false
                }
            }

        case .failure(let error):
            // User cancelled — don't show error for cancellation
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                return
            }
            errorMessage = "Sign-in failed. Please try again."
        }
    }

    // MARK: - Nonce helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
