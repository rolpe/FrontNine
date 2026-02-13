//
//  ProfileSetupViewModel.swift
//  Front Nine
//

import Foundation

enum HandleStatus: Equatable {
    case empty
    case tooShort
    case invalid
    case checking
    case available
    case taken
}

@MainActor @Observable
final class ProfileSetupViewModel {
    var displayName: String = ""
    var handle: String = ""
    var handleStatus: HandleStatus = .empty
    var isSaving = false
    var saveError: String?

    private let authService: AuthService
    private var checkTask: Task<Void, Never>?

    var sanitizedHandle: String {
        String(handle
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }
            .prefix(30))
    }

    var isValid: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty && handleStatus == .available
    }

    init(authService: AuthService, initialName: String = "") {
        self.authService = authService
        self.displayName = initialName
    }

    func handleDidChange() {
        let sanitized = sanitizedHandle
        if sanitized != handle {
            handle = sanitized
        }

        checkTask?.cancel()

        if sanitized.isEmpty {
            handleStatus = .empty
            return
        }

        if sanitized.count < 3 {
            handleStatus = .tooShort
            return
        }

        let pattern = /^[a-z0-9_]{3,30}$/
        guard sanitized.wholeMatch(of: pattern) != nil else {
            handleStatus = .invalid
            return
        }

        handleStatus = .checking

        checkTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }

            let available = await authService.checkHandleAvailability(sanitized)
            guard !Task.isCancelled else { return }

            handleStatus = available ? .available : .taken
        }
    }

    func save() async {
        guard isValid else { return }
        isSaving = true
        saveError = nil

        do {
            try await authService.saveProfile(
                displayName: displayName.trimmingCharacters(in: .whitespaces),
                handle: handle
            )
        } catch {
            saveError = "Could not save profile. Please try again."
        }

        isSaving = false
    }
}
