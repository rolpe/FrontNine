//
//  AddCourseFlowView.swift
//  Front Nine
//

import SwiftUI
import SwiftData
import MapKit

/// Container view presented as a sheet. Manages the search → detail → rate → compare → insert flow
/// so the user never sees the rankings list flash between steps.
struct AddCourseFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) private var authService
    @Environment(RankingSyncService.self) private var syncService
    @Query(sort: \Course.rankPosition) private var courses: [Course]

    @State private var flowStep: FlowStep
    /// Tracks the existing course being re-ranked (nil for new adds)
    @State private var rerankingCourse: Course?
    /// Captures rank position before gap closure for reRanked activity
    @State private var oldRankBeforeRerank: Int?
    /// Rating selection for re-rank flow
    @State private var rerankRating: Rating?

    init(preselectedResult: CourseSearchResult? = nil) {
        if let result = preselectedResult {
            self._flowStep = State(initialValue: .detail(result))
        } else {
            self._flowStep = State(initialValue: .search)
        }
    }

    private enum FlowStep {
        case search
        case detail(CourseSearchResult)
        case quickRate(CourseSearchResult, CourseEnrichmentData?)
        case manualAdd
        case comparison(ComparisonViewModel)
    }

    private var isInComparison: Bool {
        if case .comparison = flowStep { return true }
        return false
    }

    var body: some View {
        Group {
            switch flowStep {
            case .search:
                SearchCourseView(
                    existingCourses: courses,
                    onSelectResult: { result in
                        rerankingCourse = findExistingCourse(for: result)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .detail(result)
                        }
                    },
                    onAddManually: {
                        rerankingCourse = nil
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .manualAdd
                        }
                    },
                    onCancel: {
                        dismiss()
                    }
                )

            case .detail(let result):
                CourseDetailPreviewView(
                    result: result,
                    existingCourse: rerankingCourse,
                    onBack: {
                        rerankingCourse = nil
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .search
                        }
                    },
                    onAddAndRate: { enrichmentData in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .quickRate(result, enrichmentData)
                        }
                    }
                )

            case .quickRate(let result, let enrichmentData):
                if let course = rerankingCourse {
                    rerankRatingView(result: result, enrichmentData: enrichmentData, course: course)
                } else {
                    QuickRateView(
                        searchResult: result,
                        existingCourse: nil,
                        enrichmentData: enrichmentData,
                        onCourseReady: handleCourseAdded,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                flowStep = .detail(result)
                            }
                        }
                    )
                }

            case .manualAdd:
                AddCourseView(onCourseAdded: handleCourseAdded)

            case .comparison(let vm):
                ComparisonView(viewModel: vm, onComplete: {
                    if rerankingCourse != nil {
                        applyRerank(vm)
                    } else {
                        insertCourse(vm)
                    }
                    dismiss()
                })
            }
        }
        .interactiveDismissDisabled(isInComparison)
    }

    // MARK: - Re-rank Rating View

    @ViewBuilder
    private func rerankRatingView(result: CourseSearchResult, enrichmentData: CourseEnrichmentData?, course: Course) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Map peek with back button
                ZStack(alignment: .topLeading) {
                    MapPeekView(
                        coordinate: result.coordinate,
                        courseName: result.name,
                        height: 120
                    )

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .detail(result)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(FNColors.sage)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.leading, 12)
                    .padding(.top, 12)
                }

                VStack(alignment: .leading, spacing: 24) {
                    // Course info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.name)
                            .font(FNFonts.header())
                            .foregroundStyle(FNColors.text)
                            .tracking(-0.5)

                        Text(Course.formatLocation(city: result.city, state: result.state, country: result.country))
                            .font(FNFonts.subtext())
                            .foregroundStyle(FNColors.textLight)
                    }

                    RatingPickerView(selectedRating: $rerankRating)

                    // Continue button
                    if let rating = rerankRating {
                        Button {
                            // Update rating + metadata from search
                            course.rating = rating
                            course.latitude = result.coordinate.latitude
                            course.longitude = result.coordinate.longitude
                            if let data = enrichmentData {
                                course.par = data.par
                                course.courseRating = data.courseRating
                                course.slope = data.slope
                                course.totalYards = data.totalYards
                                course.golfCourseApiId = data.golfCourseApiId
                                course.teeName = data.teeName
                            }
                            course.updatedAt = Date()
                            handleCourseReranked(course)
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
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .background(FNColors.cream)
        .onAppear {
            rerankRating = course.rating
        }
    }

    // MARK: - Existing Course Matching

    private func findExistingCourse(for result: CourseSearchResult) -> Course? {
        let key = CourseSearchViewModel.courseKey(name: result.name, city: result.city, state: result.state)
        return courses.first { course in
            CourseSearchViewModel.courseKey(name: course.name, city: course.city, state: course.state) == key
        }
    }

    // MARK: - New Course Flow

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
                flowStep = .comparison(vm)
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

        // Sync to Firestore
        if let uid = authService.userProfile?.uid {
            let shiftedIds = Set(vm.rankShifts.keys)
            let allCoursesAfter = courses + [vm.newCourse]
            syncService.syncCourse(vm.newCourse, uid: uid)
            syncService.syncAfterRankChange(allCourses: allCoursesAfter, changedIds: shiftedIds, uid: uid)
            let newCount = allCoursesAfter.count
            syncService.updateRankingCount(newCount, uid: uid)
            authService.userProfile?.rankingCount = newCount

            // Write activity
            if let profile = authService.userProfile {
                syncService.writeActivity(
                    type: .ranked,
                    course: vm.newCourse,
                    newRank: vm.finalRank,
                    oldRank: nil,
                    actorProfile: profile,
                    uid: uid
                )
            }
        }
    }

    // MARK: - Re-rank Flow

    private func handleCourseReranked(_ course: Course) {
        // Capture old rank before gap closure
        oldRankBeforeRerank = course.rankPosition

        // Close the rank gap at the old position
        CourseDeleter.closeRankGap(for: course, in: courses)

        // Build comparisons against all OTHER courses (excluding the one being re-ranked)
        let otherCourses = courses.filter { $0.id != course.id }
        let vm = ComparisonViewModel(
            newCourse: course,
            existingCourses: otherCourses
        )

        if vm.needsComparisons {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                flowStep = .comparison(vm)
            }
        } else {
            applyRerank(vm)
            dismiss()
        }
    }

    private func applyRerank(_ vm: ComparisonViewModel) {
        let otherCourses = courses.filter { $0.id != vm.newCourse.id }
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
        vm.newCourse.rankPosition = vm.finalRank

        // Sync to Firestore
        if let uid = authService.userProfile?.uid {
            var changedIds = Set(shifts.keys)
            changedIds.insert(vm.newCourse.id)
            syncService.syncAfterRankChange(allCourses: Array(courses), changedIds: changedIds, uid: uid)

            // Write activity
            if let profile = authService.userProfile {
                syncService.writeActivity(
                    type: .reRanked,
                    course: vm.newCourse,
                    newRank: vm.finalRank,
                    oldRank: oldRankBeforeRerank,
                    actorProfile: profile,
                    uid: uid
                )
            }
        }
    }
}
