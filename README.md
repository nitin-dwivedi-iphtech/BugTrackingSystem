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
- **Admin** — creates teams and projects, manages employees, edits teams, adds/deletes projects; only sees the **Team** and **Project** tabs
- **Project Manager** — edits only the projects assigned to their team, reports bugs, assigns bugs to developers, changes priority, and drives the Open → Assigned / Closed → Reopened transitions
- **Developer** — fixes bugs assigned to them and drives the Assigned → In Progress → Ready for Testing (and Reopened → In Progress) transitions
- **QA Tester** — reports bugs, edits bugs they reported or that are assigned to them, verifies Ready for Testing / Fixed bugs, and reviews ready-for-testing work

### Modules
- **Dashboard** — greeting banner with avatar, bug overview stats, status distribution chart, and a list of recently reported bugs (non-admin)
- **Reports** — analytics with five report types (Status, Priority, Severity, Project, Monthly) rendered as bar and donut charts; summary stat cards
- **Projects** — list with search; admin can add (with a Team picker) and delete (with confirmation, cascades bugs + team and unassigns members); team members shown in the project detail
- **Bugs** — create/edit/report with platform (iOS/Android/Web), free-text device name, OS/app versions, severity/priority/status, due date, screenshot and file attachments; filterable (status/priority/severity/project), sortable and searchable list showing project, module, assigned developer, severity badge and status
- **Bug Details** — rich detail screen with a role-gated status workflow, priority/assignee controls (PM), description/steps/results, fix details, screenshot and attachment previews with share support
- **Comments** — add, edit, and delete comments per bug (only your own comments are editable)
- **Attachments** — attach images, videos, or log files while creating/editing a bug; thumbnails and share links in details
- **My Bug / Notifications** — segmented tab with assigned/reported/recently-updated bugs and a notifications feed (assignments, status updates, comments, priority changes)
- **Team Members** — role-filtered, searchable member list (name/email/designation)
- **Teams** — admin creates a team (exactly 1 PM, ≥1 Developer, ≥1 QA Tester) with its first project and members; edit/add/remove members
- **Settings** — profile with photo picker, dark mode toggle, about section (app name/version/build/minimum iOS), and logout

## Tech Stack

- **SwiftUI** — declarative UI
- **Core Data** — local persistence (Employee, Team, Project, Bug, Comment, Attachment entities)
- **Swift Charts** — status distribution and analytics charts
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
│   ├── AttachmentEnum.swift           # Attachment file types (image/video/log) + draft model
│   ├── ReportEnum.swift               # Report types (status/priority/severity/project/monthly)
│   ├── NotificationModel.swift        # Notification types + item model
│   └── DashboardModels.swift          # Dashboard/report data models
├── View/
│   ├── SplashScreen/SplashView.swift
│   ├── AuthScreen/
│   │   ├── AuthView.swift             # Login / Sign Up + admin mode + role picker
│   │   └── TopCardView.swift
│   ├── DashboardScreen/
│   │   ├── DashboardView.swift        # Greeting banner, stats, reports entry
│   │   ├── DashboardSections.swift    # Stat cards, status chart, recent bugs
│   │   └── StatCard.swift
│   ├── ReportsScreen/
│   │   ├── ReportsView.swift          # Report picker + content
│   │   └── ReportChartSections.swift  # Bar / donut / monthly charts
│   ├── ProjectScreen/
│   │   ├── ProjectView.swift          # Projects list (admin add/delete, search)
│   │   ├── ProjectRow.swift
│   │   ├── AddProjectScreen/AddProjectView.swift    # Team picker included
│   │   ├── ProjectEditScreen/ProjectEditView.swift  # PM edits own team's projects
│   │   └── ProjectDetailScreen/ProjectDetailView.swift  # Members card + edit gate
│   ├── BugScreen/
│   │   ├── BugView.swift              # Bug list with filters + search + sort
│   │   ├── BugRow.swift               # Project, module, assignee, severity/status badges
│   │   ├── AddBugScreen/AddBugView.swift
│   │   ├── BugEditScreen/BugEditView.swift
│   │   └── BugDetailsScreen/
│   │       ├── BugDetailsView.swift   # Status workflow + priority/assignee + attachments
│   │       └── CommentSectionView.swift
│   ├── MyBugScreen/
│   │   ├── MyWorkView.swift           # Segmented: My Bugs / Notifications
│   │   └── MyBugView.swift            # Assigned / Raised / Recently Updated
│   ├── NotificationsScreen/NotificationsView.swift  # Grouped by type + refresh
│   ├── MembersScreen/MembersView.swift  # Role filter + search
│   ├── TeamScreen/
│   │   ├── TeamView.swift
│   │   ├── AddTeamScreen/AddTeamView.swift
│   │   ├── TeamDetailScreen/TeamDetailView.swift
│   │   ├── TeamEditScreen/
│   │   │   ├── TeamEditView.swift
│   │   │   └── AvailableEmployeesView.swift
│   │   ├── AddEmployeeScreen/AddEmployeeView.swift
│   │   └── ListOfEmployeesScreen/
│   │       ├── ListOfEmployeesView.swift
│   │       └── EmployeeRowView.swift
│   ├── SettingsScreen/
│   │   ├── SettingsView.swift
│   │   └── SettingsSections.swift     # Profile, appearance, about, logout
│   └── CustomViews/
│       ├── CustomTextFieldView.swift  # Reusable field (secure/plain + icon + lineLimit)
│       ├── CustomSearchView.swift     # Reusable search bar
│       ├── BugThumbnailView.swift     # Reusable bug avatar/thumbnail
│       └── AttachmentViews.swift      # AttachmentRowView + AddAttachmentButtons
├── ViewModel/
│   ├── AuthViewModel.swift
│   ├── ContentViewModel.swift
│   ├── ProjectViewModel.swift         # Fetch/create/delete/canEdit + role helpers
│   ├── TeamViewModel.swift
│   ├── BugViewModel.swift             # Fetch/create/edit, transitions, comments, attachments
│   ├── MembersViewModel.swift
│   ├── MyBugViewModel.swift
│   ├── NotificationsViewModel.swift
│   ├── ReportsViewModel.swift
│   └── SettingsViewModel.swift
├── Core/
│   ├── Session/SessionManager.swift   # Singleton session + sign up / sign in / auto login
│   ├── Helper/KeyChainHelper.swift    # Keychain save / read / delete
│   ├── Extension/Extension.swift      # saveData() + Employee.createAdmin()
│   └── Theme/AppTheme.swift           # Shared button gradient (Color.appButtonGradient)
├── Persistence.swift                  # NSPersistentContainer + admin seeding
├── ContentView.swift                  # Auth <-> main content switch (admin vs user tabs)
└── BugTrackingSystemApp.swift         # App entry (+ dark mode preference)
```

## Getting Started

1. Open `BugTrackingSystem.xcodeproj` in Xcode.
2. Select a simulator or device with iOS 26.5+.
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
- **Teams**: created by admin (a team is always created together with its first project) and must contain exactly 1 PM, at least 1 Developer, and at least 1 QA Tester. Members can be added/removed later. Additional projects are added from the Project tab's **+** button by picking the target team.
- **Projects**: admin adds (linked to a team) and deletes (cascades bugs + team, unassigns members); PM can edit only their own team's projects; Dev/QA view read-only. Project detail shows its team members with a PM/Dev/QA breakdown.
- **Bugs**: fetched across all of the team's projects; filters for status/priority/severity/project plus search and sort (date/priority/status). The add-bug button is shown to PMs and QA Testers. Assigning a bug while it is `Open` auto-moves it to `Assigned`.
- **Bug workflow** (role-gated transitions):
  - `Open` → `Assigned` (PM only)
  - `Assigned` → `In Progress` (assigned developer only)
  - `In Progress` → `Ready for Testing` (assigned developer only)
  - `Ready for Testing` → `Fixed` / `Reopened` (QA only; `Fixed` requires fix details)
  - `Fixed` → `Closed` / `Reopened` (QA only)
  - `Reopened` → `In Progress` (assigned developer only)
  - `Closed` → `Reopened` (PM only)
- **Comments & attachments**: anyone can comment; only the author can edit/delete. Attachments (image/video/log) are picked via PhotosPicker/file importer, stored in Core Data, shown as thumbnails in rows, and shareable from the details screen.
- **Reports**: reached from the Dashboard; shows summary cards plus a chart per report type (Status bar, Priority/Severity donut, Project bar, Monthly bar for the last 12 months).
- **Notifications**: generated from team bugs for assignments, status updates, comments by others, and high/critical priority changes; grouped by type with relative timestamps.

### Session (`SessionManager.swift`)
- Singleton (`SessionManager.shared`) using `@Observable`.
- `signUp` — creates an `Employee` record in Core Data + saves token to Keychain.
- `signIn` — fetches `Employee` matching email/password/role, then stores the token.
- `autoLogin` — restores the session from the Keychain on app restart.

### Theme & Appearance (`Core/Theme/AppTheme.swift`)
- Shared `Color.appButtonGradient` (blue) backed by the `appPrimary` color asset — used consistently by every button in the app.
- Dark mode preference is persisted with `@AppStorage("darkMode")` and applied via `preferredColorScheme` in the app entry.

## Requirements

- iOS 26.5+
- Xcode 17+
- Swift 5.9+

## Notes

- The `Bug_Tracking_System.drawio` diagram describes the broader system design.
