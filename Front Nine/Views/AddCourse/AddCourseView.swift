//
//  AddCourseView.swift
//  Front Nine
//

import SwiftUI
import SwiftData

struct AddCourseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = AddCourseViewModel()

    var onCourseAdded: ((Course) -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                CourseFormFields(
                    name: $viewModel.courseName,
                    city: $viewModel.city,
                    state: $viewModel.state,
                    courseType: $viewModel.courseType,
                    holeCount: $viewModel.holeCount,
                    rating: $viewModel.selectedRating,
                    notes: $viewModel.notes,
                    namePlaceholder: "e.g. Pebble Beach Golf Links",
                    showDividerBeforeRating: true
                )
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .background(FNColors.cream)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider().background(FNColors.tan.opacity(0.25))
                    Button(action: submitCourse) {
                        Text("Add Course")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(
                                viewModel.isValid ? .white : FNColors.textLight
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(buttonColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .animation(.easeInOut(duration: 0.2), value: viewModel.selectedRating)
                    }
                    .disabled(!viewModel.isValid)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(FNColors.cream)
            }
            .navigationTitle("Add Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FNColors.textLight)
                }
            }
        }
    }

    private var buttonColor: Color {
        guard viewModel.isValid, let rating = viewModel.selectedRating else {
            return FNColors.tan
        }
        return rating.tierColor
    }

    private func submitCourse() {
        guard let course = viewModel.buildCourse() else { return }
        if let onCourseAdded {
            onCourseAdded(course)
        } else {
            dismiss()
        }
    }
}

#Preview {
    AddCourseView()
        .modelContainer(for: Course.self, inMemory: true)
}
