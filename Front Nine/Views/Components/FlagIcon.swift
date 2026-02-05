//
//  FlagIcon.swift
//  Front Nine
//

import SwiftUI

enum FlagVariant {
    case filled, outlined, dashed
}

extension Rating {
    var flagVariant: FlagVariant {
        switch self {
        case .loved: return .filled
        case .liked: return .outlined
        case .disliked: return .dashed
        }
    }
}

struct FlagIcon: View {
    let variant: FlagVariant
    let color: Color
    var size: CGFloat = 22

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24

            // Pole
            let polePath = Path { path in
                path.move(to: CGPoint(x: 5 * scale, y: 4 * scale))
                path.addLine(to: CGPoint(x: 5 * scale, y: 21 * scale))
            }
            context.stroke(polePath, with: .color(color), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))

            // Flag shape
            let flagPath = Path { path in
                path.move(to: CGPoint(x: 5 * scale, y: 4 * scale))
                path.addCurve(
                    to: CGPoint(x: 9.5 * scale, y: 3 * scale),
                    control1: CGPoint(x: 5 * scale, y: 4 * scale),
                    control2: CGPoint(x: 6.5 * scale, y: 3 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 17 * scale, y: 5 * scale),
                    control1: CGPoint(x: 12.5 * scale, y: 3 * scale),
                    control2: CGPoint(x: 14 * scale, y: 5 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 20 * scale, y: 4 * scale),
                    control1: CGPoint(x: 18.5 * scale, y: 5 * scale),
                    control2: CGPoint(x: 19.5 * scale, y: 4.5 * scale)
                )
                path.addLine(to: CGPoint(x: 20 * scale, y: 14 * scale))
                path.addCurve(
                    to: CGPoint(x: 17 * scale, y: 15 * scale),
                    control1: CGPoint(x: 19.5 * scale, y: 14.5 * scale),
                    control2: CGPoint(x: 18.5 * scale, y: 15 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 9.5 * scale, y: 13 * scale),
                    control1: CGPoint(x: 14 * scale, y: 15 * scale),
                    control2: CGPoint(x: 12.5 * scale, y: 13 * scale)
                )
                path.addCurve(
                    to: CGPoint(x: 5 * scale, y: 14 * scale),
                    control1: CGPoint(x: 6.5 * scale, y: 13 * scale),
                    control2: CGPoint(x: 5 * scale, y: 14 * scale)
                )
            }

            switch variant {
            case .filled:
                context.fill(flagPath, with: .color(color.opacity(0.25)))
                context.stroke(flagPath, with: .color(color), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            case .outlined:
                context.stroke(flagPath, with: .color(color), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
            case .dashed:
                context.stroke(flagPath, with: .color(color), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round, dash: [3, 3]))
            }
        }
        .frame(width: size, height: size)
    }
}
