# Front Nine — Local MVP Product Requirements Document

## Overview

**App Name:** Front Nine  
**Platform:** iOS (iPhone)  
**Version:** MVP 1.0  
**Scope:** Local-only, single user, no authentication

### What This MVP Is

A simple, local-only app that lets a user:
1. Add golf courses they've played
2. Rate each course with a simple sentiment
3. Build a personal ranking through head-to-head comparisons

### What This MVP Is NOT

- No user accounts or authentication
- No cloud sync or external APIs
- No social features (friends, sharing, activity feeds)
- No external course database integration
- No maps or location services

---

## Core Features

### 1. Course Management

**Add a Course**

Users manually enter course information:
- Course name (required)
- City (required)
- State (required)
- Course type: Public or Private (required)
- Number of holes: 9 or 18 (default: 18)
- Notes (optional, 280 characters max)

**View Courses**

- List of all added courses
- Sort by: Date added, Alphabetical, Ranking position
- Search/filter by name

**Edit/Delete Course**

- Edit any course details
- Delete a course (with confirmation)
- Deleting a course removes it from rankings

---

### 2. Rating System

**Three-Tier Sentiment Rating**

When adding or rating a course, user selects one:

| Rating | Label | Description |
|--------|-------|-------------|
| 😍 | Loved it | Exceptional experience, would return anytime |
| 👍 | Liked it | Good experience, would play again |
| 👎 | Didn't like it | Below expectations, wouldn't prioritize returning |

**Rating Rules**
- Every course must have a rating
- Rating can be changed at any time
- Changing a rating triggers re-ranking comparisons

---

### 3. Comparison-Based Ranking

This is the core differentiator. Instead of arbitrary scores, users make relative comparisons to determine ranking position.

**How It Works**

1. User adds a new course and gives it a sentiment rating
2. App presents 2-4 head-to-head matchups against courses with the same or adjacent sentiment tier
3. Each matchup asks: "Which course would you rather play tomorrow?"
4. User taps their choice
5. App uses responses to slot the new course into the correct ranking position

**Comparison Algorithm (Simplified)**

```
When a new course is added with rating R:

1. Get all existing courses in the same tier (R)
2. If tier has 0 courses → new course is ranked #1 in tier, done
3. If tier has 1 course → one comparison, winner ranks higher
4. If tier has 2+ courses → use binary search approach:
   a. Compare against middle-ranked course in tier
   b. Based on result, narrow to upper or lower half
   c. Repeat until position found (max ~3-4 comparisons)
   
Tier boundaries:
- "Loved it" courses always rank above "Liked it"
- "Liked it" courses always rank above "Didn't like it"
```

**Comparison UI**
- Full-screen comparison view
- Two course cards side by side (or stacked on smaller screens)
- Each card shows: Course name, City/State, User's rating
- Clear "Choose" button on each card
- "I can't decide" option (randomly places new course in the middle of remaining range)
- Progress indicator: "Comparison 2 of 3"

**Manual Ranking Adjustment**

After initial placement:
- User can view full ranking list
- Drag-and-drop to manually reorder
- Manual changes override algorithm placement
- No re-comparisons triggered by manual moves

---

### 4. Ranking Display

**My Rankings Screen**

- Ordered list showing all rated courses
- Each item shows:
  - Rank number (#1, #2, etc.)
  - Course name
  - City, State
  - Sentiment icon (😍/👍/👎)
- Visual separation between sentiment tiers (subtle divider or background color)

**Empty State**

When no courses added:
- Friendly illustration
- "Add your first course to start building your rankings"
- Prominent "Add Course" button

---

## Data Model

### Course Entity

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | UUID | Yes | Auto-generated |
| name | String | Yes | Max 100 characters |
| city | String | Yes | Max 50 characters |
| state | String | Yes | US state (2-letter or full name) |
| courseType | Enum | Yes | public, private |
| holeCount | Int | Yes | 9 or 18 |
| notes | String | No | Max 280 characters |
| rating | Enum | Yes | loved, liked, disliked |
| rankPosition | Int | Yes | Global rank (1 = best) |
| createdAt | Date | Yes | Auto-generated |
| updatedAt | Date | Yes | Auto-updated |

### Persistence

- Use SwiftData for local storage
- All data persists on device
- No cloud backup in MVP (user's iCloud backup will capture app data)

---

## User Flows

### Flow 1: First Launch

1. App opens to empty My Rankings screen
2. Empty state message with "Add Course" CTA
3. User taps "Add Course"
4. Enters course details
5. Selects sentiment rating
6. (No comparisons needed for first course)
7. Course appears as #1 in rankings
8. Success feedback, return to rankings

### Flow 2: Adding Second+ Course

1. User taps "Add Course" (+ button or tab)
2. Enters course details
3. Selects sentiment rating
4. Comparison flow begins:
   - "Let's figure out where [Course] fits in your rankings"
   - First comparison presented
   - User makes choice
   - If more comparisons needed, next one appears
   - Progress shown: "2 of 3"
5. Final placement shown: "[Course] is now #X in your rankings!"
6. Return to rankings with new course highlighted

### Flow 3: Changing a Rating

1. User taps on course in rankings or course list
2. Course detail view opens
3. User taps current rating to change
4. Selects new sentiment
5. If tier changed:
   - "This will affect [Course]'s ranking. Continue?"
   - New comparisons presented within new tier
6. Ranking updated, user returned to list

### Flow 4: Manual Reorder

1. User is on My Rankings screen
2. Taps "Edit" or enters edit mode (long press)
3. Drag handles appear on each row
4. User drags course to new position
5. List reorders in real-time
6. User taps "Done"
7. New ranking positions saved

---

## Screen Inventory

| Screen | Purpose |
|--------|---------|
| My Rankings | Primary view showing ordered list of all courses |
| Add Course | Form to add new course details + rating |
| Course Detail | View/edit single course, change rating |
| Comparison | Head-to-head matchup during ranking flow |
| Course List | Alternative view: all courses sortable/filterable |

---

## UI/UX Notes

**Design Principles**
- Clean, minimal interface
- Golf-inspired but not cheesy (no excessive green/plaid)
- Fast interactions — adding and comparing should feel snappy
- Satisfying feedback on ranking changes (subtle animations)

**Key Interactions**
- Swipe to delete courses (with confirmation)
- Pull to... nothing in MVP (no refresh needed for local)
- Tap course to view details
- Long press or Edit button for reorder mode

**Accessibility**
- VoiceOver support for all screens
- Dynamic Type support
- Sufficient color contrast

---

## Technical Considerations

**iOS Version:** 17.0+ (required for SwiftData)

**Frameworks:**
- SwiftUI for UI
- SwiftData for persistence
- No external dependencies for MVP

**Architecture:**
- MVVM pattern
- Keep it simple — this is a small app

---

## Success Criteria for MVP

Before moving to next phase, validate:

1. ✅ Can add courses with all required fields
2. ✅ Can rate courses with 3-tier system
3. ✅ Comparison flow correctly determines ranking position
4. ✅ Rankings display correctly with tier separation
5. ✅ Can manually reorder rankings
6. ✅ Can edit course details
7. ✅ Can delete courses
8. ✅ Data persists across app launches
9. ✅ App handles edge cases (first course, ties, etc.)

---

## Out of Scope (Future Phases)

**Phase 2: Authentication & Cloud**
- User accounts (Sign in with Apple)
- Cloud sync (CloudKit or Firebase)
- Cross-device sync

**Phase 3: Course Database**
- Integration with golf course API
- Auto-complete when adding courses
- Course photos and additional metadata
- Google Maps integration for course location

**Phase 4: Social**
- Friend connections
- View friends' rankings
- Activity feed
- Share rankings externally

**Phase 5: Enhancements**
- Wishlist / "Want to Play" list
- Course photos (user uploaded)
- Advanced filters and search
- Widgets
- Apple Watch companion

---

## Development Approach

Given the goal of building in small, testable chunks:

**Suggested Build Order:**

1. **Data layer first** — SwiftData model, CRUD operations
2. **Course list view** — Display courses, empty state
3. **Add course form** — Basic input, validation
4. **Rating selection** — Three-tier picker component
5. **Basic ranking** — Simple ordered list (no comparisons yet)
6. **Comparison engine** — Algorithm logic, unit tested
7. **Comparison UI** — Head-to-head screen
8. **Full flow integration** — Wire it all together
9. **Manual reorder** — Drag and drop
10. **Polish** — Animations, edge cases, testing

Each chunk should be testable independently before moving to the next.
