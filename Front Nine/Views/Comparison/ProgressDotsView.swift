//
//  ProgressDotsView.swift
//  Front Nine
//

import SwiftUI

struct ProgressDotsView: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? FNColors.sage : FNColors.tan)
                    .frame(
                        width: step == currentStep ? 24 : 8,
                        height: 8
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }
}

#Preview("Step 1 of 3") {
    ProgressDotsView(currentStep: 0, totalSteps: 3)
        .padding()
        .background(FNColors.cream)
}

#Preview("Step 2 of 3") {
    ProgressDotsView(currentStep: 1, totalSteps: 3)
        .padding()
        .background(FNColors.cream)
}

#Preview("Step 3 of 3") {
    ProgressDotsView(currentStep: 2, totalSteps: 3)
        .padding()
        .background(FNColors.cream)
}

#Preview("Single step") {
    ProgressDotsView(currentStep: 0, totalSteps: 1)
        .padding()
        .background(FNColors.cream)
}
