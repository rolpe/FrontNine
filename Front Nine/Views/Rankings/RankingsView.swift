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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddCourse = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(FNColors.sage)
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
        }
    }

    private func tierSection(rating: Rating, courses: [Course]) -> some View {
        Section {
            ForEach(courses, id: \.id) { course in
                CourseRowView(course: course, onDelete: deleteCourse)
                    .listRowBackground(FNColors.cream)
                    .listRowSeparatorTint(FNColors.tan.opacity(0.25))
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        } header: {
            TierHeaderView(rating: rating)
        }
    }

    private func deleteCourse(_ course: Course) {
        let deletedRank = course.rankPosition
        modelContext.delete(course)

        // Close the gap: shift all courses ranked below this one up by 1
        for c in courses where c.rankPosition > deletedRank {
            c.rankPosition -= 1
        }
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
