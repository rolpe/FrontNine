//
//  RankingsView.swift
//  Front Nine
//

import SwiftUI
import SwiftData

struct RankingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Course.rankPosition) private var courses: [Course]
    @State private var showingAddCourse = false

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
                    .scrollContentBackground(.hidden)
                }
            }
            .background(FNColors.cream)
            .navigationTitle("My Rankings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !courses.isEmpty {
                        EditButton()
                            .foregroundStyle(FNColors.sage)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(FNColors.sage)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { courseID in
                if let course = courses.first(where: { $0.id == courseID }) {
                    CourseDetailView(course: course)
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseFlowView()
            }
        }
    }

    private func tierSection(rating: Rating, courses: [Course]) -> some View {
        Section {
            ForEach(courses, id: \.id) { course in
                NavigationLink(value: course.id) {
                    CourseRowView(course: course, onDelete: deleteCourse)
                }
                .listRowBackground(FNColors.cream)
                .listRowSeparatorTint(FNColors.tan.opacity(0.25))
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .onMove { source, destination in
                moveCourses(in: rating, from: source, to: destination)
            }
        } header: {
            TierHeaderView(rating: rating)
        }
    }

    private func moveCourses(in rating: Rating, from source: IndexSet, to destination: Int) {
        var tierCourses = courses.filter { $0.rating == rating }
        let ranks = tierCourses.map { $0.rankPosition }
        tierCourses.move(fromOffsets: source, toOffset: destination)
        for (index, course) in tierCourses.enumerated() {
            course.rankPosition = ranks[index]
        }
    }

    private func deleteCourse(_ course: Course) {
        CourseDeleter.deleteCourse(course, allCourses: courses, modelContext: modelContext)
    }
}

#Preview("Empty State") {
    RankingsView()
        .modelContainer(for: Course.self, inMemory: true)
}

#Preview("With Courses") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Course.self, configurations: config)

    let sampleCourses: [(String, String, String, CourseType, Rating, Int)] = [
        ("Pebble Beach Golf Links", "Pebble Beach", "CA", .public, .loved, 1),
        ("Pinehurst No. 2", "Pinehurst", "NC", .public, .loved, 2),
        ("Bandon Dunes", "Bandon", "OR", .public, .loved, 3),
        ("Bethpage Black", "Farmingdale", "NY", .public, .liked, 4),
        ("TPC Sawgrass", "Ponte Vedra Beach", "FL", .public, .liked, 5),
        ("Torrey Pines South", "La Jolla", "CA", .public, .liked, 6),
        ("Whistling Straits", "Kohler", "WI", .public, .liked, 7),
        ("Chambers Bay", "University Place", "WA", .public, .disliked, 8),
    ]

    for (name, city, state, type, rating, rank) in sampleCourses {
        let course = Course(
            name: name, city: city, state: state,
            courseType: type, rating: rating, rankPosition: rank
        )
        container.mainContext.insert(course)
    }

    return RankingsView()
        .modelContainer(container)
}
