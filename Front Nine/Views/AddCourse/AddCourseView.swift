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
                VStack(alignment: .leading, spacing: 24) {
                    FNTextField(
                        label: "Course Name",
                        placeholder: "e.g. Pebble Beach Golf Links",
                        text: $viewModel.courseName,
                        characterLimit: 100
                    )

                    HStack(alignment: .top, spacing: 12) {
                        FNTextField(
                            label: "City",
                            placeholder: "City",
                            text: $viewModel.city,
                            characterLimit: 50
                        )
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("STATE")
                                .font(FNFonts.label())
                                .foregroundStyle(FNColors.textLight)
                                .kerning(0.3)

                            Picker("State", selection: $viewModel.state) {
                                Text("--").tag("")
                                ForEach(USState.allCases) { state in
                                    Text(state.rawValue).tag(state.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FNColors.tan, lineWidth: 1.5)
                            )
                        }
                        .frame(width: 100)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("COURSE TYPE")
                            .font(FNFonts.label())
                            .foregroundStyle(FNColors.textLight)
                            .kerning(0.3)
                        HStack(spacing: 8) {
                            ForEach(CourseType.allCases, id: \.self) { type in
                                PillButtonView(
                                    title: type.rawValue,
                                    isSelected: viewModel.courseType == type,
                                    action: { viewModel.courseType = type }
                                )
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("HOLES")
                            .font(FNFonts.label())
                            .foregroundStyle(FNColors.textLight)
                            .kerning(0.3)
                        HStack(spacing: 8) {
                            PillButtonView(
                                title: "9",
                                isSelected: viewModel.holeCount == 9,
                                action: { viewModel.holeCount = 9 }
                            )
                            PillButtonView(
                                title: "18",
                                isSelected: viewModel.holeCount == 18,
                                action: { viewModel.holeCount = 18 }
                            )
                        }
                    }

                    Divider()
                        .background(FNColors.tan)
                        .padding(.vertical, 8)

                    RatingPickerView(selectedRating: $viewModel.selectedRating)

                    FNTextField(
                        label: "Notes (optional)",
                        placeholder: "Any thoughts about this course...",
                        text: $viewModel.notes,
                        characterLimit: 280
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .background(FNColors.cream)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider().background(FNColors.tan.opacity(0.25))
                    Button(action: submitCourse) {
                        Text("Add & Rank This Course")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(
                                viewModel.isValid ? .white : FNColors.textLight
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                viewModel.isValid ? FNColors.sage : FNColors.tan
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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

    private func submitCourse() {
        guard let course = viewModel.buildCourse() else { return }

        // Temporary rank assignment until comparison engine is wired (Chunk 8)
        let descriptor = FetchDescriptor<Course>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        course.rankPosition = count + 1

        modelContext.insert(course)
        onCourseAdded?(course)
        dismiss()
    }
}

#Preview {
    AddCourseView()
        .modelContainer(for: Course.self, inMemory: true)
}
