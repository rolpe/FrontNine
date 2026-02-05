//
//  FNTheme.swift
//  Front Nine
//

import SwiftUI

enum FNColors {
    static let cream     = Color(red: 250/255, green: 248/255, blue: 245/255) // #FAF8F5
    static let text      = Color(red: 44/255,  green: 44/255,  blue: 44/255)  // #2C2C2C
    static let textLight = Color(red: 107/255, green: 99/255,  blue: 96/255)  // #6B6360
    static let sage      = Color(red: 125/255, green: 154/255, blue: 120/255) // #7D9A78
    static let tan       = Color(red: 212/255, green: 196/255, blue: 176/255) // #D4C4B0
    static let coral     = Color(red: 232/255, green: 165/255, blue: 152/255) // #E8A598
    static let warmGray  = Color(red: 160/255, green: 147/255, blue: 138/255) // #A0938A
}

enum FNFonts {
    static func header() -> Font { .system(size: 28, weight: .semibold) }
    static func body() -> Font { .system(size: 17, weight: .regular) }
    static func bodyMedium() -> Font { .system(size: 17, weight: .medium) }
    static func label() -> Font { .system(size: 13, weight: .semibold) }
    static func rankNumber() -> Font { .system(size: 24, weight: .light) }
    static func subtext() -> Font { .system(size: 14, weight: .regular) }
    static func cardTitle() -> Font { .system(size: 22, weight: .semibold) }
    static func cardSubtitle() -> Font { .system(size: 16, weight: .regular) }
}

extension Rating {
    var tierColor: Color {
        switch self {
        case .loved: return FNColors.coral
        case .liked: return FNColors.sage
        case .disliked: return FNColors.warmGray
        }
    }

    var tierLabel: String {
        switch self {
        case .loved: return "LOVED"
        case .liked: return "LIKED"
        case .disliked: return "DIDN'T LOVE"
        }
    }
}
