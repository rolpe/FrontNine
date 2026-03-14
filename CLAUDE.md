# Front Nine

An iOS golf course ranking app. Users search for real golf courses via MapKit, rate them with 3-tier sentiment (Loved / Liked / Didn't Like), then rank them within tiers via head-to-head comparisons using binary search. Supports international courses. Social features include following, shared rankings, activity feeds, and profile photos. Released on the App Store.

## Working Style
Be a thought partner, not just an executor. Before implementing changes, briefly propose alternatives that could improve the user experience or technical approach. Challenge my assumptions and suggest better paths when you see them. Only skip this step if I explicitly say "just do it" or make clear I want exact execution. Pause for manual testing between implementation chunks.

## UX Principles
This is a premium consumer app, not a developer tool. Every feature should feel polished and invisible:
- **No manual steps for automatable work.** If the system can do it, the user shouldn't have to. Sync, caching, data migration — all invisible. Never add a button for something that should happen automatically.
- **Think from the user's perspective first.** Before proposing any UI, ask: "Would a non-technical user understand why this exists?" If the answer is "only if they understand the backend," it's wrong.
- **Infrastructure is invisible.** Users don't know or care about Firestore, sync, or cloud storage. They just expect their data to be there. Never expose implementation details in the UI.
- **Fewer choices > more choices.** Don't ask the user to make decisions the app can make for them. Smart defaults over configuration.
- **Progressive disclosure.** Show what matters now, hide what doesn't. Advanced options (if any) should be tucked away, not prominent.

## Tech Stack
- SwiftUI + SwiftData, targeting iOS 17+
- Swift Testing framework (`@Test`, `#expect`, `import Testing`)
- Xcode 16+ with `PBXFileSystemSynchronizedRootGroup` — new files on disk are auto-detected, no pbxproj editing needed
- Apple MapKit for course search (`MKLocalSearch` with multi-strategy parallel search)
- Firebase Storage for profile photos
- CoreLocation for nearby course discovery
- GolfCourseAPI.com for course enrichment (par, slope, rating, yardage, tee boxes)
- Firebase (FirebaseAuth + FirebaseFirestore via SPM) for authentication, user profiles, social graph, and rankings sync

## Architecture & Directory Structure
```
Front Nine/
  Models/
    Course.swift              — @Model entity, CourseType & Rating enums, locationText/formatLocation helpers
    CourseSearchResult.swift   — Value type from MapKit search (not @Model), iOS 26 API compat
    CourseEnrichmentData.swift — Lightweight value type for threading enrichment through add-course flow
    GolfCourseAPIModels.swift  — Codable structs for GolfCourseAPI.com responses
    USState.swift             — 50 states + DC enum with bidirectional name↔abbreviation lookup
    UserProfile.swift         — Codable/Hashable struct for Firestore user profile (uid, displayName, handle, dates, social counts, privacy)
    FirestoreRanking.swift    — Codable/Hashable value type mapping Course fields to Firestore document
    ActivityItem.swift        — Codable/Hashable/Identifiable value type for activity feed events (ranked/reRanked)
  Theme/
    FNTheme.swift             — FNColors, FNFonts, Rating display extensions (tierColor, tierLabel)
  Services/
    RankingEngine.swift       — Pure-logic binary search ranking, RankedCourse value type (no SwiftUI/SwiftData imports)
    CourseSearchService.swift  — Actor wrapping MKLocalSearch with 3-strategy parallel search + nearby search
    ProfilePhotoService.swift  — @MainActor @Observable Firebase Storage upload/download/cache for profile photos
    GolfCourseAPIService.swift — @MainActor service wrapping GolfCourseAPI.com (search, fetch, in-memory cache)
    CourseEnrichmentService.swift — @Observable matching + tee selection logic, suffix stripping for API search
    LocationManager.swift     — @Observable CLLocationManager wrapper (one-shot location, permission handling)
    CourseDeleter.swift       — Static helpers for rank gap closure + deletion
    AuthService.swift         — @MainActor @Observable auth state manager (Sign in with Apple, profile CRUD)
    FirestoreService.swift    — @MainActor Firestore wrapper + FirestoreServiceProtocol for testability (users, rankings, follows, search, activity)
    RankingSyncService.swift  — @MainActor @Observable service syncing rankings to Firestore on all mutation points + activity writes
    FollowService.swift       — @MainActor @Observable follow/unfollow with local isFollowingCache, batch Firestore writes
    ActivityFeedService.swift — @MainActor fan-out-on-read service, fetches activity from followed users in parallel
    Secrets.swift             — API key (gitignored)
  ViewModels/
    AddCourseViewModel.swift    — Manual add form state, validation, country auto-fill from locale
    ComparisonViewModel.swift   — Binary search state machine for head-to-head ranking
    CourseSearchViewModel.swift — Search query/results/loading/error state, recent searches (UserDefaults), already-added detection
    ProfileSetupViewModel.swift    — Handle validation (format + availability), sanitization, save logic
    OtherUserProfileViewModel.swift — Rankings loading, follow state, privacy checks for other users
    UserSearchViewModel.swift      — User search by handle/display name with debounce
    ActivityFeedViewModel.swift    — Feed state, time-grouped items (today/week/earlier), staleness refresh, relative time
  Views/
    Rankings/
      RankingsView.swift          — Main screen, List with tier sections, nav to detail, add sheet, debug seed tools
      CourseRowView.swift          — Row: rank number, tier color bar, name, location, pills, swipe delete
      TierSectionView.swift       — Section header with FlagIcon + tier label
      RankingsEmptyStateView.swift — Empty state CTA
    AddCourse/
      AddCourseFlowView.swift      — Sheet container: 5-state enum flow (search→detail→quickRate→manualAdd→comparison)
      SearchCourseView.swift       — Search bar with 400ms debounce, results/loading/error/empty states
      CourseSearchResultRow.swift   — Search result row: flag icon, name, location, chevron
      CourseDetailPreviewView.swift — Selected course preview with enrichment data, tee picker, disambiguation
      CourseStatsCard.swift         — Reusable 4-column stats card (par/rating/slope/yards + tee name)
      TeePickerView.swift          — Horizontal capsule tee selector
      CourseDisambiguationView.swift — Multi-course club picker when API returns ambiguous matches
      QuickRateView.swift          — Compact form: course type + holes + rating, map overlay, sticky bottom button
      AddCourseView.swift          — Full manual add form (NavigationStack, CourseFormFields)
      PillButtonView.swift         — Reusable capsule toggle button (interactive selection)
      RatingPickerView.swift       — 3-option rating selector with color bars and flag icons
    Activity/
      ActivityFeedView.swift    — Main feed: List with time sections, dual navigation targets, empty states, pull-to-refresh
      ActivityCardView.swift    — Card: user row (avatar + action text) + nested course card (tier bar, rank capsule, re-rank indicator)
    Components/
      CourseFormFields.swift   — Reusable form: name, city, state/region, country, type, holes, rating, notes
      FNTextField.swift        — Styled text input with label, char limit, tan border
      FlagIcon.swift           — Canvas-drawn flag with filled/outlined/dashed variants per rating
      MapPeekView.swift        — Non-interactive map with gradient fade and Directions button
      TypePill.swift           — InfoPill base + TypePill (private only) + HolesPill (non-18 only)
      InitialsAvatarView.swift — Initials-based avatar circle for user profiles
      ProfileAvatarView.swift  — Photo avatar with initials fallback, auto-downloads from Firebase Storage
      CameraPickerView.swift   — UIImagePickerController wrapper for camera/photo library
      AppleSignInButton.swift  — Reusable Sign in with Apple (nonce, SHA256, credential exchange, error handling)
    Comparison/
      ComparisonView.swift     — Head-to-head: two-pin map, tier-colored dots, cards, OR divider, "I can't decide"
      ComparisonMapView.swift  — Two-pin map with auto-fit region, recreated per comparison step via .id()
      ComparisonCardView.swift — Selectable course card with name + location
      ProgressDotsView.swift   — Animated dot progress indicator with configurable activeColor
    MainTabView.swift          — Root TabView with 3 tabs (Rankings/Activity/Profile), navigation path per tab, tab-switch reset
    CourseDetailView.swift     — Detail/edit/re-rank: map peek, stats card, read-only cards, edit mode (no rating), re-rank flow (rating picker → comparisons)
    Profile/
      ProfileFlowView.swift    — Sheet container routing by AuthState (signedOut→signIn, needsSetup→setup, signedIn→profile)
      SignInView.swift          — Sign in with Apple button, nonce/SHA256, Firebase credential, error handling
      ProfileSetupView.swift   — Display name + @handle picker with real-time availability check
      ProfileView.swift        — Signed-in profile: stats row, privacy toggle, sign out, delete account
    Social/
      UserSearchView.swift         — User search UI with handle/name search
      OtherUserProfileView.swift   — Other user's profile with rankings display, follow button, privacy lock
      OtherUserCourseRow.swift     — Read-only course row with chevron for social rankings
      SocialCourseDetailView.swift — Read-only course detail from FirestoreRanking, "Add to My Rankings" CTA
      FollowListView.swift         — Followers/following list with follow buttons and navigation to profiles
  Front_NineApp.swift          — @main entry, SwiftData ModelContainer, Firebase init, AuthService/RankingSyncService/FollowService/ProfilePhotoService environment, forced light mode
  Supporting Files/
    FrontNine_MVP_PRD.md       — Original product requirements document

Front NineTests/
  RankingEngineTests.swift           — Binary search logic, tier boundaries, rank shifting
  ComparisonViewModelTests.swift     — State machine, final rank, rank shifts
  AddCourseViewModelTests.swift      — Validation, buildCourse, reset
  CourseSearchResultTests.swift      — USState lookup, CourseSearchResult equality
  CourseSearchViewModelTests.swift   — Recent searches (save/dedup/limit/persist), already-added detection
  CourseEnrichmentServiceTests.swift — Matching, tee selection, suffix stripping, enrichment data
  GolfCourseAPIModelsTests.swift     — JSON decoding, missing fields, empty arrays
  Front_NineTests.swift              — Course model init, enums, SwiftData persistence, enrichment fields
  UserProfileTests.swift             — UserProfile init, Codable round-trip, firestoreData output, Equatable
  ProfileSetupViewModelTests.swift   — Handle validation/sanitization, isValid, async availability, debounce
  FollowServiceTests.swift           — Follow/unfollow logic, cache behavior
  ActivityItemTests.swift            — Model init, Codable round-trip, firestoreData, toFirestoreRanking, Equatable/Hashable
  ActivityFeedViewModelTests.swift   — Initial state, loadFeed, time grouping, relativeTime, refresh, staleness
```

## Key Design Decisions & Conventions

### Patterns
- **@Observable** for ViewModels (not ObservableObject)
- **actor** for network services (CourseSearchService)
- **Callbacks** for parent-child communication (onCourseAdded, onBack, onComplete — not NavigationPath)
- **State machine** enum in AddCourseFlowView for multi-step flow — no nested NavigationStack
- **Pure logic separation**: RankingEngine + RankedCourse have zero SwiftUI/SwiftData imports
- **In-sheet navigation**: AddCourseFlowView keeps entire flow within one sheet to avoid rankings list flashing
- **Progressive auth**: App works fully without signing in. Profile icon in toolbar opens auth sheet. AuthService injected via `.environment()`
- **AuthService**: `@MainActor @Observable` with `AuthState` enum (unknown/signedOut/signedIn/needsSetup). Firebase auth state listener drives transitions. Injectable `FirestoreServiceProtocol` for testability
- **Profile flow**: ProfileFlowView routes by `authState` — same state-machine sheet pattern as AddCourseFlowView
- **Firestore sync**: RankingSyncService injected via `.environment()`, syncs on all mutation points (add, delete, re-rank, edit, drag reorder, re-rank from detail/search)
- **Social navigation**: Value-based `NavigationLink(value:)` with `.navigationDestination(for:)` — `FirestoreRanking` and `UserProfile` both `Hashable` for this
- **FollowService**: `@MainActor @Observable` with local `isFollowingCache` dictionary for instant UI, batch Firestore writes (following + followers subcollections + denormalized counts)
- **Social course detail**: Read-only view from `FirestoreRanking`, matches local courses via `courseKey()` for "on your list" indicator, builds `CourseSearchResult` for "Add to My Rankings" sheet
- **ProfileDestination enum**: Used for value-based navigation to followers/following lists from profile stats
- **TabView architecture**: 3-tab layout (Rankings/Activity/Profile) with `@State` NavigationPath per tab. Tab switch resets previous tab's navigation via `.onChange(of: selectedTab)`
- **Activity feed**: Fan-out-on-read from Firestore activity subcollections. `ActivityFeedService` queries followed users in parallel via `withTaskGroup`, error-resilient per user. Time-grouped display (Today/This Week/Earlier). Smart refresh on tab re-appearance: staleness threshold (60s) + following count change detection
- **AppleSignInButton**: Extracted reusable component with nonce generation, SHA256, credential exchange. Used by both SignInView and ActivityFeedView empty state
- **ProfilePhotoService**: `@MainActor @Observable` with tracked `[String: UIImage]` dictionary (NOT NSCache — invisible to @Observable). `downloading: Set<String>` prevents duplicate fetches. `Storage.storage()` must be a computed property (deferred init)
- **Course search strategy**: Three parallel `MKLocalSearch` queries merged with dedup: (1) golf-filtered + " golf" appended, (2) golf-filtered with exact query, (3) unfiltered + " golf" with category allowlist. Covers miscategorized courses (Montauk Downs = Park) and generic names (The Park)
- **Dark mode**: Forced light via `.preferredColorScheme(.light)` on root view — app not designed for dark mode

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
- **Course search via MapKit**: Three parallel search strategies for maximum coverage → select → preview → quick rate → comparison → insert. "Add manually" fallback below results
- **Manual add course**: Full form with name, city, state/region, country, type, holes, rating, notes
- **Binary search ranking**: Head-to-head comparisons within rating tier, O(log N) comparisons
- **Rankings display**: Tier sections (Loved/Liked/Didn't Like), rank numbers, tier color bars, scrolling (non-sticky) headers, crown flourish on #1 course
- **Course detail**: Read-only card layout, map peek, stats card (enriched courses), edit mode (with CourseFormFields), delete with confirmation
- **Unified re-rank flow**: "Re-rank" button on CourseDetailView → rating picker → comparison flow. Same pattern for re-rank from search (rating-only picker, not full QuickRateView). Rating removed from edit mode — re-rank handles all rating changes
- **Manual reorder**: Edit mode with drag handles (onMove within tier)
- **International courses**: Country field, locale-aware display, non-US state/region support
- **GolfCourseAPI enrichment**: Auto-fetch par, slope, course rating, yardage when previewing a course; tee picker (defaults to White/middle); disambiguation UI for multi-course clubs; graceful degradation (silent failure, card simply hidden)
- **Map peek**: Non-interactive map with gradient fade on CourseDetailPreviewView, QuickRateView (back button overlay), and CourseDetailView; Directions button on detail view
- **Comparison map**: Two-pin map at top of comparison screen showing both courses, auto-fit region with generous padding, recreated per step via `.id()`
- **TypePill / HolesPill**: Exception-only pills — TypePill shows only for private courses, HolesPill shows only for non-18-hole courses
- **Recent searches**: Last 4 searches persisted in UserDefaults, shown as tappable chips in search empty state, case-insensitive dedup
- **Already-added detection**: Green checkmark badge on search results for courses already in rankings (indicator only, still tappable)
- **Error state polish**: Coral-tinted card with "Try Again" button for real errors; MapKit "no results" handled as empty state (not error)
- **Notes in quick rate**: Notes field available during both new add and re-rank flows
- **Nearby courses**: LocationManager with one-shot location, auto-load when authorized, permission prompt/denied/settings UI, max 5 results in search empty state
- **Keyboard dismissal**: `.scrollDismissesKeyboard(.immediately)` + `.onTapGesture` on search ScrollView
- **Tier-colored progress dots**: Comparison screen progress dots tinted to rating tier color (coral/sage/warmGray)
- **Debug tools** (`#if DEBUG`): Ladybug toolbar button → seed 8 sample courses / delete all courses, seed/delete test members
- **Firebase Auth (Phase 1)**: Sign in with Apple via Firebase, Firestore user profiles with unique @handles, progressive auth (no sign-in gate), profile setup flow with real-time handle availability, sign out + delete account
- **Profile UI**: ProfileFlowView sheet from toolbar icon (sage when signed in, warmGray when not), SignInView with Apple branding, ProfileSetupView with handle validation, ProfileView with stats row (ranked/followers/following), privacy toggle, member-since date
- **Firestore sync (Phase 2)**: RankingSyncService syncs rankings to Firestore on all 8 mutation points — add, delete, re-rank, edit, drag reorder, rating change, re-rank from detail, re-rank from search. Denormalized ranking count on user profile. Auto-sync on every mutation (no manual sync button)
- **Social foundation (Phase 2)**: Follow/unfollow with instant UI (local cache + batch Firestore writes), user search by @handle or display name, view other users' profiles and rankings (tier sections, read-only course rows with chevrons, crown flourish on #1), tappable course detail from social rankings, "Add to My Rankings" CTA (pre-seeds AddCourseFlowView), "#N on your list" indicator with tier-colored dot, "Ranked by [name]" attribution, privacy toggle (private = followers-only rankings), followers/following lists with follow/unfollow buttons and navigation
- **Smart defaults**: courseType defaults to `.public` (most common), holeCount defaults to 18 — rating is the only required selection for new adds
- **App icon**: AppStore-1024.png in asset catalog (light mode only, iOS derives dark/tinted)
- **Activity feed (Phase 3)**: 3-tab layout (Rankings/Activity/Profile), activity events written on rank/re-rank, fan-out-on-read feed from followed users, time-grouped display (Today/This Week/Earlier), dual navigation targets (avatar → profile, card → course detail), pull-to-refresh, smart staleness refresh (60s + follow count change), three empty states (not signed in with Apple sign-in button, not following with Find Members CTA, no activity), reusable AppleSignInButton component
- **Profile photos**: Upload via camera or photo library, Firebase Storage backed, cached in tracked dictionary for @Observable reactivity, auto-download on display, wired into all 6 avatar sites (ProfileView, OtherUserProfileView, ActivityCardView, UserSearchView, FollowListView, ProfileSetupView)
- **Dark mode protection**: `.preferredColorScheme(.light)` forces light mode app-wide
- **Backward-compatible rating rename**: "Didn't Love" → "Didn't Like" with custom `init(from:)` decoder for legacy data + Firestore `normalizeRating()` helper
- **Firestore deduplication**: `fetchRankings()` deduplicates by document ID and name+city+state key
- **221 unit tests passing** across 13 test files (includes Rating decoding tests)

### Not Yet Implemented
- **Course pages**: Aggregate view of a course across all users
- **Additional auth providers**: Email/password, Google sign-in
- **Comparison fallback**: No visual fallback when manually-added courses lack coordinates (map area is simply blank)
- **Push notifications**: New follower, shared ranking activity

## Next Steps

App is live on the App Store (v1.2). Core ranking + auth + sync + social + activity feed + profile photos are all complete. Potential next: course pages (aggregate view across users), push notifications, additional auth providers.

## Gotchas & Context a New Session Would Miss

### Build Environment
- **Simulator**: Use `iPhone 17 Pro` — no iPhone 16 simulator available
- **Build command**: `xcodebuild -scheme "Front Nine" -destination "platform=iOS Simulator,name=iPhone 17 Pro"`
- **iOS 26 SDK**: `MKMapItem.placemark` is deprecated. CourseSearchResult.swift uses `#available(iOS 26, *)` branching — new API uses `mapItem.location` + `mapItem.addressRepresentations` (MKAddress/MKAddressRepresentations), falls back to placemark for older iOS

### Swift Pitfalls
- `Self.staticProperty` **cannot** be used as a stored property default initializer (covariant Self error). Use a file-private `let` or closure instead — see AddCourseViewModel.swift's `defaultCountry`
- `@MainActor` is required for MKMapItem property access from actor contexts. CourseSearchResult.from(mapItem:) is `@MainActor`, called via `await MainActor.run {}` in CourseSearchService
- Default parameter expressions are **nonisolated** even on `@MainActor` inits — use optional params with `??` in body instead
- `actor` → `@MainActor final class` for API services when all callers are MainActor (e.g., GolfCourseAPIService) — avoids isolation mismatch, URLSession async methods still run in background
- `Map(initialPosition:)` only sets map position on first render — use `.id(someChangingValue)` to force SwiftUI to recreate the Map when the region should change

### Data Model Subtleties
- `Course.state` is a non-optional `String` but CAN be empty (international courses without states)
- `Course.country` is `String?` — nil for courses added before the country field existed, nil when left blank
- `RankedCourse` (in RankingEngine.swift) mirrors Course fields as a value type — when you add fields to Course, also add to RankedCourse and update all construction sites (ComparisonViewModel x2, AddCourseFlowView.applyRerank, CourseDetailView.applyReranking, RankingEngineTests)
- `RankedCourse` fields: id, name, city, state, country, rating, rankPosition, latitude, longitude
- `Course` enrichment fields: `par: Int?`, `courseRating: Double?`, `slope: Int?`, `totalYards: Int?`, `golfCourseApiId: Int?`, `teeName: String?` — populated from GolfCourseAPI.com, nil for manual adds or API failures
- `Course.hasEnrichedData` computed property: true when par, courseRating, or slope is non-nil
- `rankPosition` is 1-indexed, contiguous within the full list (not per-tier)
- SwiftData handles additive schema migration automatically (new optional fields just work)

### GolfCourseAPI Integration
- CourseEnrichmentService strips common suffixes ("Golf Club", "Country Club", "Golf Course", etc.) from course names before API search — improves match rates
- Matching algorithm: search by name → 0 results = silent nil, 1 result = auto-match, multiple = filter by city → 1 city match = auto-match, else show disambiguation
- Default tee selection: prefer "White" male tee, fallback to middle by yardage
- `CourseEnrichmentData` is a lightweight value type threaded through the flow (preview → quickRate → Course creation) — not stored as a separate entity
- API key stored in `Secrets.swift` (gitignored), accessed via `Secrets.golfCourseAPIKey`

### Flow Architecture
- AddCourseFlowView's 5-state enum: `.search` → `.detail(CourseSearchResult)` → `.quickRate(CourseSearchResult, CourseEnrichmentData?)` → `.comparison(ComparisonViewModel)`. Also `.manualAdd` as alternate path from search.
- **Preselected result**: `init(preselectedResult:)` skips to `.detail` step — used by "Add to My Rankings" from SocialCourseDetailView
- **Re-rank from search**: `@State rerankingCourse: Course?` tracks whether we're re-ranking an existing course. When set, `.quickRate` step shows a rating-only picker (not full QuickRateView) → comparisons → re-insert. Enrichment data and coordinates applied silently on Continue.
- The manual add path (AddCourseView) has its **own NavigationStack** — don't nest another one
- `interactiveDismissDisabled` only during `.comparison` step (prevent data loss mid-ranking)
- Keyboard is explicitly resigned before entering comparison: `UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder)...)`

### Search & Already-Added
- `CourseSearchViewModel` has injectable `UserDefaults` (for testability) and `existingCourseKeys: Set<String>` for duplicate detection
- `courseKey(name:city:state:)` is the shared normalization function — used in both ViewModel and AddCourseFlowView.findExistingCourse
- MapKit throws `MKError.placemarkNotFound` when no results found — caught and treated as empty results, not an error
- Recent searches saved after every search attempt (success or failure), capped at 4, case-insensitive dedup
- **MapKit POI miscategorization**: Apple categorizes some golf courses as parks (e.g. Montauk Downs = `MKPOICategoryPark`). Generic course names (e.g. "The Park") fail when " golf" is appended. Three parallel searches solve both problems
- **Search dedup**: By both `id` (name+coordinates) and name+city. Same-name/same-coordinates duplicates cause SwiftUI `ForEach` ghost rows. Name+city dedup catches same course from different searches
- **Category allowlist for broad search**: Only `.golf`, `.park`, `.nationalPark`, `.campground`, and uncategorized POIs pass through. Allowlist > blocklist because new Apple categories default to excluded
- **"Add manually" fallback**: Shown below search results for discoverability — users may not know the option exists on the empty search screen

### Firestore Sync & Social
- RankingSyncService and FollowService are injected via `.environment()` in `Front_NineApp.swift` alongside AuthService
- **Denormalized counts**: When pushing follower/following/ranking counts to Firestore, also update local `authService.userProfile` — UI reads from local state, not Firestore
- **Swift exclusivity**: NEVER read and write `authService.userProfile?` in one expression (e.g. `x?.count = max(0, (x?.count ?? 0) - 1)` crashes). Always read into a local first
- **Firestore rules don't cascade to subcollections** — each subcollection (`rankings`, `following`, `followers`) needs its own explicit `match` rules
- **`test_` UID prefix convention** for debug test data — never collides with Apple Sign In UIDs
- **NavigationLink in List vs ScrollView**: `List` auto-shows chevrons for NavigationLink; `ScrollView` + `VStack` needs explicit chevron + `.contentShape(Rectangle())` for full-row tapping
- **`FirestoreRanking` and `UserProfile` need `Hashable`** for value-based `NavigationLink(value:)`
- **AddCourseFlowView preselectedResult**: Optional `CourseSearchResult?` init parameter — when provided, starts at `.detail` step (skips search). Used by "Add to My Rankings" from social course detail. Default `nil` preserves existing behavior
- **Social course matching**: Uses `CourseSearchViewModel.courseKey(name:city:state:)` to match `FirestoreRanking` to local `Course` — same normalization as search duplicate detection

### Profile Photos & Firebase Storage
- `ProfilePhotoService` uses `[String: UIImage]` dictionary, NOT `NSCache` — `NSCache` mutations are invisible to `@Observable`, causing photos to randomly appear/disappear
- `Storage.storage()` must be a computed property (same pattern as `Firestore.firestore()`) — eagerly initializing before `FirebaseApp.configure()` crashes
- `downloading: Set<String>` prevents duplicate concurrent fetches for the same photo
- Firebase Storage rules: path segments can't contain dots — use `match /profile_photos/{fileName}` with `fileName.matches(uid + '.jpg')`
- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` required in Info.plist for camera/photo access

### Firebase & Auth
- `Firestore.firestore()` must be deferred (computed property) — `FirestoreService` is created before `FirebaseApp.configure()` runs
- Firestore production mode default rules deny ALL reads/writes — custom security rules must be deployed
- Views should NOT `import FirebaseAuth` — expose needed properties through `AuthService` computed properties (e.g., `isSignedIn`, `currentUserDisplayName`)
- Apple only sends user's full name on FIRST sign-in ever — must store during profile setup
- `user.delete()` may throw `requiresRecentLogin` if auth token is stale — Phase 1 shows error message asking user to sign out and back in
- `AuthService` uses `FirestoreServiceProtocol` for testability — tests inject `MockFirestoreService`
- `@State private var authService = AuthService()` in app entry — `startListening()` deferred to `.task` (after `FirebaseApp.configure()`)
- Sign out doesn't need confirmation (easily reversible); delete account does
- `ProfileSetupViewModel` debounces handle availability checks by 500ms, cancels in-flight checks on new input

### Rating Rename (Didn't Love → Didn't Like)
- `Rating.disliked` raw value is `"Didn't Like"` — custom `init(from decoder:)` maps legacy `"Didn't Love"` to `.disliked`
- `FirestoreService.normalizeRating()` converts `"Didn't Love"` → `"Didn't Like"` when parsing Firestore documents (rankings and activity items)
- Existing Firestore data still contains `"Didn't Love"` — normalization happens at read time, not migrated in place

### Location Display
- `Course.formatLocation(city:state:country:)` is the single source of truth for formatting — used by Course.locationText, all search result views, and ComparisonView
- Country is hidden when it matches the user's locale country (via `Locale.current.region?.identifier` → `localizedString(forRegionCode:)`)
- `RankedCourse` does NOT have a `locationText` property (to keep RankingEngine pure) — ComparisonView calls `Course.formatLocation()` directly for the compare course

## GitHub
- Repo: https://github.com/rolpe/FrontNine.git
- Main branch: `main`
