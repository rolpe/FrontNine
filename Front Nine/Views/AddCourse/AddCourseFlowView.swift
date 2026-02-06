//
//  AddCourseFlowView.swift
//  Front Nine
//

import SwiftUI
import SwiftData

/// Container view presented as a sheet. Manages the add → compare → insert flow
/// so the user never sees the rankings list flash between steps.
struct AddCourseFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.rankPosition) private var courses: [Course]

    @State private var comparisonVM: ComparisonViewModel?

    var body: some View {
        Group {
            if let vm = comparisonVM {
                ComparisonView(viewModel: vm, onComplete: {
                    insertCourse(vm)
                    dismiss()
                })
            } else {
                AddCourseView(onCourseAdded: handleCourseAdded)
            }
        }
        .interactiveDismissDisabled(comparisonVM != nil)
    }

    private func handleCourseAdded(_ course: Course) {
        let vm = ComparisonViewModel(
            newCourse: course,
            existingCourses: Array(courses)
        )

        if vm.needsComparisons {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                comparisonVM = vm
            }
        } else {
            insertCourse(vm)
            dismiss()
        }
    }

    private func insertCourse(_ vm: ComparisonViewModel) {
        for existingCourse in courses {
            if let newRank = vm.rankShifts[existingCourse.id] {
                existingCourse.rankPosition = newRank
            }
        }
        vm.newCourse.rankPosition = vm.finalRank
        modelContext.insert(vm.newCourse)
    }
}
