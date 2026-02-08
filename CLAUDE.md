# Front Nine

A local-only iOS golf course ranking app. Users search for real golf courses via MapKit, rate them with 3-tier sentiment (Loved / Liked / Didn't Love), then rank them within tiers via head-to-head comparisons using binary search. Supports international courses.

## Working Style
Be a thought partner, not just an executor. Before implementing changes, briefly propose alternatives that could improve the user experience or technical approach. Challenge my assumptions and suggest better paths when you see them. Only skip this step if I explicitly say "just do it" or make clear I want exact execution. Pause for manual testing between implementation chunks.

## Tech Stack
- SwiftUI + SwiftData, targeting iOS 17+
- Swift Testing framework (`@Test`, `#expect`, `import Testing`)
- Xcode 16+ with `PBXFileSystemSynchronizedRootGroup` — new files on disk are auto-detected, no pbxproj editing needed
- Apple MapKit for course search (`MKLocalSearch` with golf POI filter)
- No external dependencies

## Architecture & Directory Structure
```
Front Nine/
  Models/
    Course.swift           — @Model entity, CourseType & Rating enums, locationText/formatLocation helpers
    CourseSearchResult.swift — Value type from MapKit search (not @Model), iOS 26 API compat
    USState.swift          — 50 states + DC enum with bidirectional name↔abbreviation lookup
  Theme/
    FNTheme.swift          — FNColors, FNFonts, Rating display extensions (tierColor, tierLabel)
  Services/
    RankingEngine.swift    — Pure-logic binary search ranking (NO SwiftUI/SwiftData imports)
    CourseSearchService.swift — Actor wrapping MKLocalSearch with golf POI filter
    CourseDeleter.swift    — Static helpers for rank gap closure + deletion
  ViewModels/
    AddCourseViewModel.swift    — Manual add form state, validation, country auto-fill from locale
    ComparisonViewModel.swift   — Binary search state machine for head-to-head ranking
    CourseSearchViewModel.swift — Search query/results/loading/error state, recent searches (UserDefaults), already-added detection
  Views/
    Rankings/
      RankingsView.swift          — Main screen, List with tier sections, nav to detail, add sheet
      CourseRowView.swift          — Row: rank number, tier color bar, name, location, swipe delete
      TierSectionView.swift       — Section header with FlagIcon + tier label
      RankingsEmptyStateView.swift — Empty state CTA
    AddCourse/
      AddCourseFlowView.swift      — Sheet container: 5-state enum flow (search→detail→quickRate→manualAdd→comparison)
      SearchCourseView.swift       — Search bar with 400ms debounce, results/loading/error/empty states
      CourseSearchResultRow.swift   — Search result row: flag icon, name, location, chevron
      CourseDetailPreviewView.swift — Selected course preview with "Add & Rate" button
      QuickRateView.swift          — Compact form: course type + holes + rating, sticky bottom button
      AddCourseView.swift          — Full manual add form (NavigationStack, CourseFormFields)
      PillButtonView.swift         — Reusable capsule toggle button (interactive selection)
      RatingPickerView.swift       — 3-option rating selector with color bars and flag icons
    Components/
      CourseFormFields.swift   — Reusable form: name, city, state/region, country, type, holes, rating, notes
      FNTextField.swift        — Styled text input with label, char limit, tan border
      FlagIcon.swift           — Canvas-drawn flag with filled/outlined/dashed variants per rating
      TypePill.swift           — Read-only "PUBLIC"/"PRIVATE" capsule pill (sage-tinted)
    Comparison/
      ComparisonView.swift     — Head-to-head: two cards, OR divider, "I can't decide", progress dots
      ComparisonCardView.swift — Selectable course card with name + location
      ProgressDotsView.swift   — Animated dot progress indicator
    CourseDetailView.swift     — Detail/edit/comparison reranking: read-only cards, edit mode, rating change triggers re-rank
  Front_NineApp.swift          — @main entry, SwiftData ModelContainer, RankingsView root
  Supporting Files/
    FrontNine_MVP_PRD.md       — Original product requirements document

Front NineTests/
  RankingEngineTests.swift         — Binary search logic, tier boundaries, rank shifting
  ComparisonViewModelTests.swift   — State machine, final rank, rank shifts
  AddCourseViewModelTests.swift    — Validation, buildCourse, reset
  CourseSearchResultTests.swift    — USState lookup, CourseSearchResult equality
  CourseSearchViewModelTests.swift — Recent searches (save/dedup/limit/persist), already-added detection
  Front_NineTests.swift            — Course model init, enums, SwiftData persistence
```

## Key Design Decisions & Conventions

### Patterns
- **@Observable** for ViewModels (not ObservableObject)
- **actor** for network services (CourseSearchService)
- **Callbacks** for parent-child communication (onCourseAdded, onBack, onComplete — not NavigationPath)
- **State machine** enum in AddCourseFlowView for multi-step flow — no nested NavigationStack
- **Pure logic separation**: RankingEngine + RankedCourse have zero SwiftUI/SwiftData imports
- **In-sheet navigation**: AddCourseFlowView keeps entire flow within one sheet to avoid rankings list flashing

### Styling Rules
- All colors via `FNColors` (cream, text, textLight, sage, tan, coral, warmGray) — never hardcode
- All fonts via `FNFonts` (header, body, bodyMedium, label, subtext, etc.) — never hardcode
- 20pt horizontal padding, 12pt corner radius, 1.5pt tan borders (standard card/input style)
- Animated transitions between flow steps: `withAnimation(.easeInOut(duration: 0.3))`

### Naming
- Files match their primary type name
- Views end in `View` (except app entry)
- ViewModels end in `ViewModel`
- Tests end in `Tests`

### International Support
- Country field on Course (optional `String?`, nil for legacy courses)
- State/region is NOT required in form validation — some countries don't have states
- Country auto-fills from `Locale.current` in manual add form
- `Course.formatLocation()` shows country only when it differs from user's locale country
- Search query appends " golf" (not " golf course") for better international results
- US states auto-abbreviated via `USState.abbreviation(for:)`, other regions stored as-is

## Current State — What's Working

### Fully Implemented
- **Course search via MapKit**: Search → select → preview → quick rate → comparison → insert
- **Manual add course**: Full form with name, city, state/region, country, type, holes, rating, notes
- **Binary search ranking**: Head-to-head comparisons within rating tier, O(log N) comparisons
- **Rankings display**: Tier sections (Loved/Liked/Didn't Love), rank numbers, tier color bars, scrolling (non-sticky) headers
- **Course detail**: Read-only card layout, edit mode (with CourseFormFields), delete with confirmation
- **Rating change re-ranking**: Edit rating → close rank gap → new comparison flow → re-insert
- **Re-rank from search**: Selecting an already-added course shows "Re-rank This Course" → pre-filled quick rate → forced comparison (never compares against itself)
- **Manual reorder**: Edit mode with drag handles (onMove within tier)
- **International courses**: Country field, locale-aware display, non-US state/region support
- **TypePill**: Read-only "PUBLIC"/"PRIVATE" capsule on rankings rows and detail view header
- **Recent searches**: Last 4 searches persisted in UserDefaults, shown as tappable chips in search empty state, case-insensitive dedup
- **Already-added detection**: Green checkmark badge on search results for courses already in rankings (indicator only, still tappable)
- **Error state polish**: Coral-tinted card with "Try Again" button for real errors; MapKit "no results" handled as empty state (not error)
- **Notes in quick rate**: Notes field available during both new add and re-rank flows
- **Debug tools** (`#if DEBUG`): Ladybug toolbar button → seed 8 sample courses / delete all courses
- **81 unit tests passing** across 6 test files

### Optional Fields (Future-Proofing)
- `par: Int?`, `courseRating: Double?`, `slope: Int?` on Course — all nil, awaiting golf-specific API

### Not Yet Implemented
- **Nearby courses** (Chunk 5): CLLocationManager, location permissions, nearby search

## Next Steps

Chunk 5 (Nearby Courses):
1. LocationManager (@Observable wrapping CLLocationManager)
2. searchNearby(coordinate:) on CourseSearchService
3. "Nearby Courses" card in search empty state
4. Permission handling (denied → Settings message)
5. Info.plist location usage description

## Gotchas & Context a New Session Would Miss

### Build Environment
- **Simulator**: Use `iPhone 17 Pro` — no iPhone 16 simulator available
- **Build command**: `xcodebuild -scheme "Front Nine" -destination "platform=iOS Simulator,name=iPhone 17 Pro"`
- **iOS 26 SDK**: `MKMapItem.placemark` is deprecated. CourseSearchResult.swift uses `#available(iOS 26, *)` branching — new API uses `mapItem.location` + `mapItem.addressRepresentations` (MKAddress/MKAddressRepresentations), falls back to placemark for older iOS

### Swift Pitfalls
- `Self.staticProperty` **cannot** be used as a stored property default initializer (covariant Self error). Use a file-private `let` or closure instead — see AddCourseViewModel.swift's `defaultCountry`
- `@MainActor` is required for MKMapItem property access from actor contexts. CourseSearchResult.from(mapItem:) is `@MainActor`, called via `await MainActor.run {}` in CourseSearchService

### Data Model Subtleties
- `Course.state` is a non-optional `String` but CAN be empty (international courses without states)
- `Course.country` is `String?` — nil for courses added before the country field existed, nil when left blank
- `RankedCourse` (in RankingEngine.swift) mirrors Course fields as a value type — when you add fields to Course, also add to RankedCourse and update all construction sites (ComparisonViewModel, CourseDetailView.applyReranking, tests)
- `rankPosition` is 1-indexed, contiguous within the full list (not per-tier)
- SwiftData handles additive schema migration automatically (new optional fields just work)

### Flow Architecture
- AddCourseFlowView's 5-state enum: `.search` → `.detail(CourseSearchResult)` → `.quickRate(CourseSearchResult)` → `.comparison(ComparisonViewModel)`. Also `.manualAdd` as alternate path from search.
- **Re-rank flow**: `@State rerankingCourse: Course?` tracks whether we're re-ranking an existing course. When set, QuickRateView pre-fills fields, button says "Re-rank", and completion updates the existing course (closeRankGap → compare against others → set new rank) instead of inserting a new one.
- The manual add path (AddCourseView) has its **own NavigationStack** — don't nest another one
- `interactiveDismissDisabled` only during `.comparison` step (prevent data loss mid-ranking)
- Keyboard is explicitly resigned before entering comparison: `UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder)...)`

### Search & Already-Added
- `CourseSearchViewModel` has injectable `UserDefaults` (for testability) and `existingCourseKeys: Set<String>` for duplicate detection
- `courseKey(name:city:state:)` is the shared normalization function — used in both ViewModel and AddCourseFlowView.findExistingCourse
- MapKit throws `MKError.placemarkNotFound` when no results found — caught and treated as empty results, not an error
- Recent searches saved after every search attempt (success or failure), capped at 4, case-insensitive dedup

### Location Display
- `Course.formatLocation(city:state:country:)` is the single source of truth for formatting — used by Course.locationText, all search result views, and ComparisonView
- Country is hidden when it matches the user's locale country (via `Locale.current.region?.identifier` → `localizedString(forRegionCode:)`)
- `RankedCourse` does NOT have a `locationText` property (to keep RankingEngine pure) — ComparisonView calls `Course.formatLocation()` directly for the compare course

## GitHub
- Repo: https://github.com/rolpe/FrontNine.git
- Main branch: `main`
