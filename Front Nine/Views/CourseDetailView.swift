//
//  CourseDetailView.swift
//  Front Nine

import SwiftUI
import SwiftData
import MapKit

struct CourseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthService.self) private var authService
    @Environment(RankingSyncService.self) private var syncService
    @Query(sort: \Course.rankPosition) private var allCourses: [Course]

    @Bindable var course: Course
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

    // Edit state (copied from course when editing begins)
    @State private var editName = ""
    @State private var editCity = ""
    @State private var editState = ""
    @State private var editCountry = ""
    @State private var editCourseType: CourseType? = .public
    @State private var editHoleCount = 18
    @State private var editNotes = ""

    // Re-rank flow
    @State private var showRerankRating = false
    @State private var rerankRating: Rating?
    @State private var comparisonVM: ComparisonViewModel?
    @State private var oldRankBeforeRerank: Int?

    private var totalCourses: Int { allCourses.count }

    var body: some View {
        Group {
            if let vm = comparisonVM {
                ComparisonView(viewModel: vm, onComplete: {
                    applyReranking(vm)
                })
                .toolbar(.hidden, for: .navigationBar)
            } else if showRerankRating {
                rerankRatingContent
            } else if isEditing {
                editContent
            } else {
                detailContent
            }
        }
        .background(FNColors.cream)
    }

    // MARK: - Read-only card layout

    private var detailContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Map peek (only for courses with coordinates)
                if course.hasCoordinates,
                   let lat = course.latitude,
                   let lon = course.longitude {
                    MapPeekView(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        courseName: course.name,
                        height: 160
                    )
                }

            VStack(alignment: .leading, spacing: 20) {
                // Course name and location
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(course.name)
                            .font(.system(size: 26, weight: .semibold, design: .serif))
                            .foregroundStyle(FNColors.text)
                            .lineSpacing(2)

                        TypePill(courseType: course.courseType)
                        HolesPill(holeCount: course.holeCount)
                    }

                    Text(course.locationText)
                        .font(.system(size: 17))
                        .foregroundStyle(FNColors.textLight)
                }

                // Rank + Rating cards side by side
                HStack(spacing: 12) {
                    rankCard
                    ratingCard
                }

                // Course stats (enriched from API)
                if course.hasEnrichedData {
                    CourseStatsCard(
                        par: course.par,
                        courseRating: course.courseRating,
                        slope: course.slope,
                        totalYards: course.totalYards,
                        teeName: course.teeName
                    )
                }

                // Course details grouped card
                detailsCard

                // Notes section
                if let notes = course.notes, !notes.isEmpty {
                    notesSection(notes)
                }

                // Re-rank button
                Button {
                    rerankRating = course.rating
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRerankRating = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 15, weight: .medium))
                        Text("Re-rank")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(FNColors.sage)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(FNColors.sage, lineWidth: 1.5)
                    )
                }

                // Actions card
                actionsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
            }
        }
        .background(FNColors.cream)
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { beginEditing() }
                    .foregroundStyle(FNColors.sage)
            }
        }
        .confirmationDialog(
            "Delete \(course.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteCourse() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove the course from your rankings.")
        }
    }

    // MARK: - Cards

    private var rankCard: some View {
        VStack(spacing: 6) {
            Text("RANK")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            Text("#\(course.rankPosition)")
                .font(.system(size: 32, weight: .semibold, design: .serif))
                .foregroundStyle(FNColors.text)

            Text("of \(totalCourses) \(totalCourses == 1 ? "course" : "courses")")
                .font(FNFonts.subtext())
                .foregroundStyle(FNColors.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
    }

    private var ratingCard: some View {
        let color = course.rating.tierColor
        return VStack(spacing: 6) {
            Text("RATING")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            FlagIcon(
                variant: course.rating.flagVariant,
                color: color,
                size: 32
            )
            .padding(.vertical, 2)

            Text(course.rating.label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 1.5)
        )
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailCardRow(label: "Type", value: course.courseType.rawValue, showDivider: true)
            detailCardRow(label: "Holes", value: course.holeCount == 0 ? "N/A" : "\(course.holeCount)", showDivider: true)
            detailCardRow(
                label: "Added",
                value: course.createdAt.formatted(date: .abbreviated, time: .omitted),
                showDivider: false
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
    }

    private func detailCardRow(label: String, value: String, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundStyle(FNColors.textLight)
                Spacer()
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(FNColors.text)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if showDivider {
                Divider()
                    .background(FNColors.tan.opacity(0.25))
                    .padding(.leading, 16)
            }
        }
    }

    private func notesSection(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES")
                .font(FNFonts.label())
                .foregroundStyle(FNColors.textLight)
                .kerning(0.3)

            Text(notes)
                .font(.system(size: 16))
                .foregroundStyle(FNColors.text)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(FNColors.tan, lineWidth: 1.5)
                )
        }
    }

    private var actionsCard: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            HStack {
                Text("Delete course")
                    .font(.system(size: 16))
                    .foregroundStyle(FNColors.coral)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(FNColors.tan, lineWidth: 1.5)
        )
    }

    // MARK: - Edit content

    private var editContent: some View {
        ScrollView {
            CourseFormFields(
                name: $editName,
                city: $editCity,
                state: $editState,
                country: $editCountry,
                courseType: $editCourseType,
                holeCount: $editHoleCount,
                rating: .constant(course.rating),
                notes: $editNotes,
                showRating: false
            )
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(FNColors.cream)
        .navigationTitle("Edit Course")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { saveEdits() }
                    .fontWeight(.semibold)
                    .foregroundStyle(FNColors.sage)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { isEditing = false }
                    .foregroundStyle(FNColors.textLight)
            }
        }
    }

    // MARK: - Re-rank rating picker

    private var rerankRatingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Course context
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.name)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(FNColors.text)

                    Text(course.locationText)
                        .font(FNFonts.body())
                        .foregroundStyle(FNColors.textLight)
                }

                RatingPickerView(selectedRating: $rerankRating)

                // Continue button
                if let rating = rerankRating {
                    Button {
                        startRerank(withRating: rating)
                    } label: {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(rating.tierColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(FNColors.cream)
        .navigationTitle("Re-rank")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRerankRating = false
                    }
                }
                .foregroundStyle(FNColors.textLight)
            }
        }
    }

    // MARK: - Actions

    private func beginEditing() {
        editName = course.name
        editCity = course.city
        editState = course.state
        editCountry = course.country ?? ""
        editCourseType = course.courseType
        editHoleCount = course.holeCount
        editNotes = course.notes ?? ""
        isEditing = true
    }

    private func saveEdits() {
        let trimmedName = editName.trimmingCharacters(in: .whitespaces)
        let trimmedCity = editCity.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedCity.isEmpty else { return }
        guard let editCourseType else { return }

        course.name = trimmedName
        course.city = trimmedCity
        course.state = editState
        let trimmedCountry = editCountry.trimmingCharacters(in: .whitespaces)
        course.country = trimmedCountry.isEmpty ? nil : trimmedCountry
        course.courseType = editCourseType
        course.holeCount = editHoleCount
        course.notes = editNotes.trimmingCharacters(in: .whitespaces).isEmpty
            ? nil
            : editNotes.trimmingCharacters(in: .whitespaces)
        course.updatedAt = Date()

        if let uid = authService.userProfile?.uid {
            syncService.syncCourse(course, uid: uid)
        }

        isEditing = false
    }

    private func startRerank(withRating newRating: Rating) {
        // Capture old rank before gap closure
        oldRankBeforeRerank = course.rankPosition

        // Close the rank gap at the current position
        let gapShiftedCourses = allCourses.filter { $0.rankPosition > course.rankPosition && $0.id != course.id }
        CourseDeleter.closeRankGap(for: course, in: allCourses)

        // Sync gap-closed courses
        if let uid = authService.userProfile?.uid {
            syncService.syncMultipleCourses(gapShiftedCourses, uid: uid)
        }

        // Update rating if changed
        if newRating != course.rating {
            course.rating = newRating
        }

        // Compare against all other courses (same tier filtered by ComparisonViewModel)
        let otherCourses = allCourses.filter { $0.id != course.id }
        let vm = ComparisonViewModel(newCourse: course, existingCourses: otherCourses)

        if vm.needsComparisons {
            withAnimation(.easeInOut(duration: 0.3)) {
                comparisonVM = vm
                showRerankRating = false
            }
        } else {
            showRerankRating = false
            applyReranking(vm)
        }
    }

    private func applyReranking(_ vm: ComparisonViewModel) {
        let otherCourses = allCourses.filter { $0.id != course.id }
        let allRanked = otherCourses.map {
            RankedCourse(
                id: $0.id, name: $0.name, city: $0.city,
                state: $0.state, country: $0.country,
                rating: $0.rating, rankPosition: $0.rankPosition,
                latitude: $0.latitude, longitude: $0.longitude
            )
        }
        let shifts = RankingEngine.shiftRanksForInsertion(
            insertAtRank: vm.finalRank, allCourses: allRanked
        )
        for c in otherCourses {
            if let newRank = shifts[c.id] {
                c.rankPosition = newRank
            }
        }
        course.rankPosition = vm.finalRank

        // Sync to Firestore
        if let uid = authService.userProfile?.uid {
            var changedIds = Set(shifts.keys)
            changedIds.insert(course.id)
            syncService.syncAfterRankChange(allCourses: allCourses, changedIds: changedIds, uid: uid)

            // Write activity
            if let profile = authService.userProfile {
                syncService.writeActivity(
                    type: .reRanked,
                    course: course,
                    newRank: vm.finalRank,
                    oldRank: oldRankBeforeRerank,
                    actorProfile: profile,
                    uid: uid,
                    allCourses: allCourses
                )
            }
        }

        comparisonVM = nil
        dismiss()
    }

    private func deleteCourse() {
        let courseId = course.id.uuidString
        let shiftedCourses = allCourses.filter { $0.rankPosition > course.rankPosition && $0.id != course.id }
        CourseDeleter.deleteCourse(course, allCourses: allCourses, modelContext: modelContext)

        // Sync to Firestore
        if let uid = authService.userProfile?.uid {
            syncService.deleteCourseFromCloud(courseId: courseId, uid: uid)
            syncService.syncMultipleCourses(shiftedCourses, uid: uid)
            let newCount = allCourses.count - 1
            syncService.updateRankingCount(newCount, uid: uid)
            authService.userProfile?.rankingCount = newCount
        }

        dismiss()
    }
}
