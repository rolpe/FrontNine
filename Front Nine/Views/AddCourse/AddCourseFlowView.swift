//
//  AddCourseFlowView.swift
//  Front Nine
//

import SwiftUI
import SwiftData

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
                QuickRateView(
                    searchResult: result,
                    existingCourse: rerankingCourse,
                    enrichmentData: enrichmentData,
                    onCourseReady: { course in
                        if rerankingCourse != nil {
                            handleCourseReranked(course)
                        } else {
                            handleCourseAdded(course)
                        }
                    },
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            flowStep = .detail(result)
                        }
                    }
                )

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
