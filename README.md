# Bug Tracking System

A bug tracking application built with **SwiftUI** and **Core Data** for iOS. Users sign in by role (Admin, Project Manager, Developer, QA Tester), and sessions are persisted securely via the Keychain.

## Features

### Authentication
- Splash screen with animated entrance and timed navigation
- Login / Sign Up with role selection and form validation
- Admin account seeded automatically on first launch
- Button loading state (spinner inside button)
- Secure token storage via Keychain (Security framework)
- Session management with `@Observable`

### Roles & Permissions
- **Admin** — creates teams and projects, manages employees, adds/deletes projects
- **Project Manager** — can edit only the projects assigned to their team; assigns bugs to developers
- **Developer** — reports & fixes bugs assigned to them, drives status transitions
- **QA Tester** — reports bugs, verifies/reopens/fixes, reviews ready-for-testing work

### Modules
- **Dashboard** — statistics and recent bug overview (non-admin)
- **Projects** — list with search; admin can add (with a Team picker) and delete (with confirmation); team members shown in the project detail
- **Bugs** — create/edit/report with platform (iOS/Android/Web), free-text device name, OS/app versions, screenshot attachment, severity/priority/status, due date; filterable & searchable list showing project, module, assigned developer, severity badge and status
- **My Bug / Notifications** — segmented tab with assigned/reported bugs and a notifications feed
- **Team Members** — role-filtered, searchable member list (name/email/designation)
- **Teams** — admin creates a team with a project and its members; edit/add employees

## Tech Stack

- **SwiftUI** — declarative UI
- **Core Data** — local persistence (Employee, Project, Team, Bug, Comment entities)
- **Security / Keychain** — secure session storage
- **Swift Observation** (`@Observable`) — reactive state (ViewModels)

## Project Structure

```
BugTrackingSystem/
├── BugTrackingSystem.xcdatamodeld     # Core Data model
├── Model/
│   ├── RoleEnum.swift                 # Roles: Admin, Project Manager, Developer, QA Tester
│   ├── ProjectEnum.swift              # Project status / OS type enums
│   ├── BugEnum.swift                  # Bug environment, severity, priority, status
│   └── DashboardModels.swift          # Dashboard data models
├── View/
│   ├── SplashScreen/SplashView.swift
│   ├── AuthScreen/
│   │   ├── AuthView.swift             # Login / Sign Up + admin mode + role picker
│   │   └── TopCardView.swift
│   ├── DashboardScreen/               # DashboardView, DashboardSections, StatCard
│   ├── ProjectScreen/
│   │   ├── ProjectView.swift          # Projects list (admin add/delete, search)
│   │   ├── ProjectRow.swift
│   │   ├── AddProjectScreen/AddProjectView.swift    # Team picker included
│   │   ├── ProjectEditScreen/ProjectEditView.swift  # PM edits own team's projects
│   │   └── ProjectDetailScreen/ProjectDetailView.swift  # Members card + edit gate
│   ├── BugScreen/
│   │   ├── BugView.swift              # Bug list with filters + search
│   │   ├── BugRow.swift               # Project, module, assignee, severity/status badges
│   │   ├── AddBugScreen/AddBugView.swift
│   │   ├── BugEditScreen/BugEditView.swift
│   │   └── BugDetailsScreen/          # BugDetailsView + CommentSectionView
│   ├── MyBugScreen/                   # MyWorkView (segmented), MyBugView
│   ├── NotificationsScreen/NotificationsView.swift
│   ├── MembersScreen/MembersView.swift  # Role filter + search
│   ├── TeamScreen/
│   │   ├── TeamView.swift
│   │   ├── AddTeamScreen/AddTeamView.swift
│   │   ├── TeamDetailScreen/TeamDetailView.swift
│   │   ├── TeamEditScreen/TeamEditView.swift
│   │   ├── AddEmployeeScreen/AddEmployeeView.swift
│   │   └── ListOfEmployeesScreen/     # ListOfEmployeesView, EmployeeRowView
│   └── CustomViews/
│       ├── CustomTextFieldView.swift  # Reusable field (secure/plain + icon + lineLimit)
│       ├── CustomSearchView.swift     # Reusable search bar
│       └── BugThumbnailView.swift     # Reusable bug avatar/icon
├── ViewModel/
│   ├── AuthViewModel.swift
│   ├── ProjectViewModel.swift         # Fetch/create/delete/canEdit + role helpers
│   ├── TeamViewModel.swift
│   ├── BugViewModel.swift
│   ├── MembersViewModel.swift
│   ├── MyBugViewModel.swift
│   ├── NotificationsViewModel.swift
│   └── ContentViewModel.swift
├── Core/
│   ├── Session/SessionManager.swift   # Singleton session + sign up / sign in / auto login
│   ├── Helper/KeyChainHelper.swift    # Keychain save / read / delete
│   ├── Extension/Extension.swift      # saveData() + Employee.createAdmin()
│   └── Theme/AppTheme.swift           # Shared button gradient (Color.appButtonGradient)
├── Persistence.swift                  # NSPersistentContainer + admin seeding
├── ContentView.swift                  # Auth <-> main content switch (admin vs user tabs)
└── BugTrackingSystemApp.swift         # App entry
```

## Getting Started

1. Open `BugTrackingSystem.xcodeproj` in Xcode.
2. Select a simulator or device with iOS 26+.
3. Press **Run**.

The **Admin** account is seeded automatically on first launch:
`admin@gmail.com` / `123456` (role: Admin).

## How It Works

### Flow
- App launches → `SplashView` → `ContentView`
- `ContentView` checks `SessionManager.shared.isLoggedIn`:
  - **Not logged in** → `AuthView` (Login / Sign Up)
  - **Logged in as Admin** → TabView with **Team** and **Project** tabs
  - **Logged in as PM / Developer / QA** → TabView with **Dashboard, Project, Bug, My Bug, Members** tabs
- Regular users sign up with non-admin roles; the Admin account is created via `Persistence.createNewAdmin()` and logs in only.

### Module behavior
- **Teams**: created by admin (a team is always created together with its first project). Additional projects are added from the Project tab's **+** button by picking the target team.
- **Projects**: admin adds (linked to a team) and deletes (cascades bugs + team, unassigns members); PM can edit only their own team's projects; Dev/QA view read-only. Project detail shows its team members with a PM/Dev/QA breakdown.
- **Bugs**: fetched across all of the team's projects; filters for status/priority/severity/project plus search; status transitions are role-gated (e.g. only the assigned developer moves Assigned → In Progress, only QA verifies Fixed).

### Session (`SessionManager.swift`)
- Singleton (`SessionManager.shared`) using `@Observable`.
- `signUp` — creates an `Employee` record in Core Data + saves token to Keychain.
- `signIn` — fetches `Employee` matching email/password/role, then stores the token.
- `autoLogin` — restores the session from the Keychain on app restart.

### Theme (`Core/Theme/AppTheme.swift`)
- Shared `Color.appButtonGradient` (blue) backed by the `appPrimary` color asset — used consistently by every button in the app.

## Requirements

- iOS 26.0+
- Xcode 17+
- Swift 5.9+

## Notes

- Password is currently stored as plain text in Core Data — future improvement: hash before storing.
- The `Bug_Tracking_System.drawio` diagram describes the broader system design.
