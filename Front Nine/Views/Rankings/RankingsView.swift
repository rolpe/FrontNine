//
//  RankingsView.swift
//  Front Nine
//

import SwiftUI
import SwiftData

struct RankingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthService.self) private var authService
    @Environment(RankingSyncService.self) private var syncService
    @Query(sort: \Course.rankPosition) private var courses: [Course]
    @State private var showingAddCourse = false
    @State private var showingProfile = false
    #if DEBUG
    @State private var showingDebugMenu = false
    #endif

    private var lovedCourses: [Course] {
        courses.filter { $0.rating == .loved }
    }

    private var likedCourses: [Course] {
        courses.filter { $0.rating == .liked }
    }

    private var dislikedCourses: [Course] {
        courses.filter { $0.rating == .disliked }
    }

    var body: some View {
        NavigationStack {
            Group {
                if courses.isEmpty {
                    RankingsEmptyStateView(onAddCourse: { showingAddCourse = true })
                } else {
                    List {
                        if !lovedCourses.isEmpty {
                            tierSection(rating: .loved, courses: lovedCourses)
                        }
                        if !likedCourses.isEmpty {
                            tierSection(rating: .liked, courses: likedCourses)
                        }
                        if !dislikedCourses.isEmpty {
                            tierSection(rating: .disliked, courses: dislikedCourses)
                        }
                    }
                    .listStyle(.plain)
                    .listSectionSpacing(.compact)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(FNColors.cream)
            .navigationTitle("My Rankings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle")
                            .foregroundStyle(authService.isSignedIn ? FNColors.sage : FNColors.warmGray)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(FNColors.sage)
                    }
                }
                #if DEBUG
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingDebugMenu = true }) {
                        Image(systemName: "ladybug")
                            .foregroundStyle(FNColors.warmGray)
                    }
                }
                #endif
            }
            #if DEBUG
            .confirmationDialog("Debug Tools", isPresented: $showingDebugMenu, titleVisibility: .visible) {
                Button("Seed 8 Sample Courses") { seedSampleCourses() }
                Button("Delete All Courses", role: .destructive) { deleteAllCourses() }
                Button("Cancel", role: .cancel) { }
            }
            #endif
            .navigationDestination(for: UUID.self) { courseID in
                if let course = courses.first(where: { $0.id == courseID }) {
                    CourseDetailView(course: course)
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseFlowView()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileFlowView()
            }
            .onChange(of: authService.authState) { _, newValue in
                guard newValue == .signedIn, !courses.isEmpty,
                      let uid = authService.userProfile?.uid else { return }
                syncService.fullSync(courses: courses, uid: uid)
                authService.userProfile?.rankingCount = courses.count
            }
        }
    }

    private func tierSection(rating: Rating, courses: [Course]) -> some View {
        Section {
            TierHeaderView(rating: rating, count: courses.count)
                .listRowBackground(FNColors.cream)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 20))

            ForEach(courses, id: \.id) { course in
                NavigationLink(value: course.id) {
                    CourseRowView(course: course, onDelete: deleteCourse)
                }
                .listRowBackground(rowBackground(for: course, rating: rating))
                .listRowSeparator(course.rankPosition == 1 ? .hidden : .automatic)
                .listRowSeparatorTint(FNColors.tan.opacity(0.25))
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .onMove { source, destination in
                moveCourses(in: rating, from: source, to: destination)
            }
        }
    }

    @ViewBuilder
    private func rowBackground(for course: Course, rating: Rating) -> some View {
        if course.rankPosition == 1 {
            ZStack {
                FNColors.cream
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [FNColors.coral.opacity(0.05), FNColors.tan.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(FNColors.coral.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            }
        } else {
            FNColors.cream.overlay(rating.tierColor.opacity(0.04))
        }
    }

    private func moveCourses(in rating: Rating, from source: IndexSet, to destination: Int) {
        var tierCourses = courses.filter { $0.rating == rating }
        let ranks = tierCourses.map { $0.rankPosition }
        tierCourses.move(fromOffsets: source, toOffset: destination)
        for (index, course) in tierCourses.enumerated() {
            course.rankPosition = ranks[index]
        }
        try? modelContext.save()

        // Sync swapped courses to Firestore
        if let uid = authService.userProfile?.uid {
            syncService.syncMultipleCourses(tierCourses, uid: uid)
        }
    }

    private func deleteCourse(_ course: Course) {
        let courseId = course.id.uuidString
        let shiftedCourses = courses.filter { $0.rankPosition > course.rankPosition && $0.id != course.id }
        CourseDeleter.deleteCourse(course, allCourses: courses, modelContext: modelContext)

        // Sync to Firestore
        if let uid = authService.userProfile?.uid {
            syncService.deleteCourseFromCloud(courseId: courseId, uid: uid)
            syncService.syncMultipleCourses(shiftedCourses, uid: uid)
            let newCount = courses.count - 1
            syncService.updateRankingCount(newCount, uid: uid)
            authService.userProfile?.rankingCount = newCount
        }
    }

    // MARK: - Debug Helpers

    #if DEBUG
    private func deleteAllCourses() {
        // Delete from Firestore first (need course IDs before local delete)
        if let uid = authService.userProfile?.uid {
            for course in courses {
                syncService.deleteCourseFromCloud(courseId: course.id.uuidString, uid: uid)
            }
            syncService.updateRankingCount(0, uid: uid)
            authService.userProfile?.rankingCount = 0
        }
        for course in courses {
            modelContext.delete(course)
        }
    }

    private func seedSampleCourses() {
        deleteAllCourses()

        let samples: [Course] = [
            Course(
                name: "Pebble Beach Golf Links", city: "Pebble Beach", state: "CA",
                courseType: .public, rating: .loved, rankPosition: 1,
                country: "United States",
                par: 72, courseRating: 75.5, slope: 145, totalYards: 6828, teeName: "Blue",
                latitude: 36.5682, longitude: -121.9487
            ),
            Course(
                name: "Augusta National Golf Club", city: "Augusta", state: "GA",
                courseType: .private, rating: .loved, rankPosition: 2,
                country: "United States",
                par: 72, courseRating: 76.2, slope: 148, totalYards: 7510,
                latitude: 33.5033, longitude: -82.0231
            ),
            Course(
                name: "St Andrews Old Course", city: "St Andrews", state: "",
                courseType: .public, rating: .loved, rankPosition: 3,
                country: "Scotland",
                par: 72, courseRating: 73.1, slope: 132, totalYards: 6721, teeName: "White",
                latitude: 56.3433, longitude: -2.8027
            ),
            Course(
                name: "Torrey Pines South", city: "La Jolla", state: "CA",
                courseType: .public, rating: .liked, rankPosition: 4,
                country: "United States",
                par: 72, courseRating: 74.6, slope: 143, totalYards: 7258, teeName: "Blue",
                latitude: 32.8998, longitude: -117.2523
            ),
            Course(
                name: "Bethpage Black", city: "Farmingdale", state: "NY",
                courseType: .public, rating: .liked, rankPosition: 5,
                country: "United States",
                par: 71, courseRating: 76.6, slope: 155, totalYards: 7468, teeName: "Blue",
                latitude: 40.7445, longitude: -73.4539
            ),
            Course(
                name: "Bandon Dunes", city: "Bandon", state: "OR",
                courseType: .public, rating: .liked, rankPosition: 6,
                country: "United States",
                par: 72, courseRating: 74.3, slope: 140, totalYards: 6732, teeName: "White",
                latitude: 43.1869, longitude: -124.3694
            ),
            Course(
                name: "Muni Executive 9", city: "Springfield", state: "IL",
                courseType: .public, holeCount: 9, rating: .disliked, rankPosition: 7,
                country: "United States",
                latitude: 39.7817, longitude: -89.6501
            ),
            Course(
                name: "Desert Winds Golf", city: "Tucson", state: "AZ",
                courseType: .public, rating: .disliked, rankPosition: 8,
                country: "United States",
                latitude: 32.2226, longitude: -110.9747
            ),
        ]

        for course in samples {
            modelContext.insert(course)
        }

        // Sync seeded courses to Firestore
        if let uid = authService.userProfile?.uid {
            syncService.fullSync(courses: samples, uid: uid)
            authService.userProfile?.rankingCount = samples.count
        }
    }
    #endif
}

#Preview("Empty State") {
    RankingsView()
        .environment(AuthService())
        .environment(RankingSyncService())
        .modelContainer(for: Course.self, inMemory: true)
}

#Preview("With Courses") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Course.self, configurations: config)

    let samples: [Course] = [
        Course(
            name: "Pebble Beach Golf Links", city: "Pebble Beach", state: "CA",
            courseType: .public, rating: .loved, rankPosition: 1,
            country: "United States",
            par: 72, courseRating: 75.5, slope: 145, totalYards: 6828, teeName: "Blue",
            latitude: 36.5682, longitude: -121.9487
        ),
        Course(
            name: "Pinehurst No. 2", city: "Pinehurst", state: "NC",
            courseType: .public, rating: .loved, rankPosition: 2,
            country: "United States",
            par: 72, courseRating: 75.3, slope: 143, totalYards: 7588, teeName: "Blue",
            latitude: 35.1954, longitude: -79.4700
        ),
        Course(
            name: "Bandon Dunes", city: "Bandon", state: "OR",
            courseType: .public, rating: .loved, rankPosition: 3,
            country: "United States",
            par: 72, courseRating: 74.3, slope: 140, totalYards: 6732, teeName: "White",
            latitude: 43.1869, longitude: -124.3694
        ),
        Course(
            name: "Bethpage Black", city: "Farmingdale", state: "NY",
            courseType: .public, rating: .liked, rankPosition: 4,
            country: "United States",
            par: 71, courseRating: 76.6, slope: 155, totalYards: 7468, teeName: "Blue",
            latitude: 40.7445, longitude: -73.4539
        ),
        Course(
            name: "TPC Sawgrass", city: "Ponte Vedra Beach", state: "FL",
            courseType: .public, rating: .liked, rankPosition: 5,
            country: "United States",
            par: 72, courseRating: 76.4, slope: 155, totalYards: 7245, teeName: "Blue",
            latitude: 30.1975, longitude: -81.3942
        ),
        Course(
            name: "Torrey Pines South", city: "La Jolla", state: "CA",
            courseType: .public, rating: .liked, rankPosition: 6,
            country: "United States",
            par: 72, courseRating: 74.6, slope: 143, totalYards: 7258, teeName: "Blue",
            latitude: 32.8998, longitude: -117.2523
        ),
        Course(
            name: "Whistling Straits", city: "Kohler", state: "WI",
            courseType: .public, rating: .liked, rankPosition: 7,
            country: "United States",
            par: 72, courseRating: 76.7, slope: 151, totalYards: 7390, teeName: "Blue",
            latitude: 43.8531, longitude: -87.7272
        ),
        Course(
            name: "Chambers Bay", city: "University Place", state: "WA",
            courseType: .public, rating: .disliked, rankPosition: 8,
            country: "United States",
            par: 72, courseRating: 74.3, slope: 138, totalYards: 7585, teeName: "Blue",
            latitude: 47.2003, longitude: -122.5731
        ),
    ]

    for course in samples {
        container.mainContext.insert(course)
    }

    return RankingsView()
        .environment(AuthService())
        .environment(RankingSyncService())
        .modelContainer(container)
}
