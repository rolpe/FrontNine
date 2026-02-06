# Front Nine

A local-only iOS golf course ranking app. Users rate courses with 3-tier sentiment (Loved / Liked / Didn't Love), then rank them within tiers via head-to-head comparisons using binary search.

## Tech Stack
- SwiftUI + SwiftData, targeting iOS 17+
- Swift Testing framework for tests (`@Test`, `#expect`, `import Testing`)
- Xcode 16+ with `PBXFileSystemSynchronizedRootGroup` — new files on disk are auto-detected, no pbxproj editing needed

## Project Structure
```
Front Nine/
  Models/          — Course @Model, CourseType & Rating enums, USState enum
  Theme/           — FNTheme (colors, fonts, Rating display extensions)
  Services/        — RankingEngine (pure-logic binary search, no SwiftUI/SwiftData)
  ViewModels/      — AddCourseViewModel, ComparisonViewModel
  Views/
    Rankings/      — RankingsView, CourseRowView, TierHeaderView, EmptyState
    AddCourse/     — AddCourseFlowView (container), AddCourseView, RatingPickerView, PillButtonView
    Comparison/    — ComparisonView, ComparisonCardView, ProgressDotsView
    Components/    — FNTextField, FlagIcon
    CourseDetailView.swift
  Supporting Files/
    Mockups/       — React JSX mockups for UI reference
Front NineTests/   — RankingEngine, ViewModel, and model tests
```

## Key Patterns
- In-sheet navigation: AddCourseFlowView keeps the add → compare → insert flow within a single sheet (no dismiss/re-present gaps)
- Rating changes on CourseDetailView trigger re-ranking via ComparisonViewModel
- RankingEngine is pure logic (no SwiftUI/SwiftData imports) for testability
- Tier boundaries are structural — each tier is a separate List Section

## GitHub
- Repo: https://github.com/rolpe/FrontNine.git
- Main branch: `main`

## Working Style
Be a thought partner, not just an executor. Before implementing changes, briefly propose alternatives that could improve the user experience or technical approach. Challenge my assumptions and suggest better paths when you see them. Only skip this step if I explicitly say "just do it" or make clear I want exact execution.
