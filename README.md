# Bug Tracking System

A bug tracking application built with **SwiftUI** and **Core Data** for iOS. Users log in / sign up by role (Project Manager, Developer, QA Tester), and sessions are persisted securely via the Keychain.

## Features

- Splash screen with animated entrance and timed navigation
- Authentication (Login / Sign Up) with role selection
- Admin mode: seeded automatically on first launch (admins log in only)
- Role-based access — e.g. only the Project Manager can add projects
- Button loading state (spinner inside button) + form validation
- Secure token storage via Keychain (Security framework)
- Session management with `@Observable`
- Local persistence with Core Data

## Tech Stack

- **SwiftUI** — declarative UI
- **Core Data** — local persistence (Employee, Project, Bug, Team, Comment entities)
- **Security / Keychain** — secure session storage
- **Swift Observation** (`@Observable`) — reactive state (ViewModels)

## Project Structure

```
BugTrackingSystem/
├── BugTrackingSystem.xcdatamodeld     # Core Data model
├── Model/
│   ├── RoleEnum.swift                 # Roles: Admin, Project Manager, Developer, QA Tester
│   └── ProjectEnum.swift              # Project-related enums
├── View/
│   ├── SplashScreen/SplashView.swift  # Splash with bounce animation + auto navigation
│   ├── AuthScreen/
│   │   ├── AuthView.swift             # Login / Sign Up + admin mode + role picker
│   │   └── TopCardView.swift          # Header card (admin tap hook)
│   ├── DashboardScreen/DashboardView.swift  # Stats overview
│   ├── ProjectScreen/
│   │   ├── ProjectView.swift          # Projects list (PM can add)
│   │   └── AddProjectScreen/AddProjectView.swift
│   ├── TeamScreen/
│   │   ├── TeamView.swift
│   │   └── AddTeamScreen/AddTeamView.swift
│   └── CustomViews/
│       ├── CustomTextFieldView.swift  # Reusable field (secure/plain + icon + lineLimit)
│       └── CustomSearchView.swift     # Reusable search bar
├── ViewModel/
│   ├── AuthViewModel.swift            # Form state, validation, submit logic
│   ├── ProjectViewModel.swift         # Role-based access helpers
│   └── ContentViewModel.swift
├── Core/
│   ├── Session/SessionManager.swift   # Singleton session + sign up / sign in / auto login
│   ├── Helper/KeyChainHelper.swift    # Keychain save / read / delete
│   ├── Extension/Extension.swift      # saveData() + Employee.createAdmin()
│   └── Theme/AppTheme.swift           # Shared button gradient (Color.appButtonGradient)
├── Persistence.swift                  # NSPersistentContainer + admin seeding
├── ContentView.swift                  # Auth <-> main content switch
└── BugTrackingSystemApp.swift         # App entry
```

## Getting Started

1. Open `BugTrackingSystem.xcodeproj` in Xcode.
2. Select a simulator or device with iOS 17+.
3. Press **Run**.

The **Admin** account is seeded automatically on first launch:
`admin@gmail.com` / `123456` (role: Admin).

## How It Works

### Flow
- App launches → `SplashView` → `ContentView`
- `ContentView` checks `SessionManager.shared.isLoggedIn`:
  - **Not logged in** → `AuthView` (Login / Sign Up)
  - **Logged in** → main content (Dashboard / Projects / Teams)
- Login / Sign Up buttons show an in-button spinner while working and stay disabled until all required fields are filled.
- Regular users sign up with non-admin roles; the Admin account is created via `Persistence.createNewAdmin()` and logs in only.

### Session (`SessionManager.swift`)
- Singleton (`SessionManager.shared`) using `@Observable`.
- `signUp` — creates an `Employee` record in Core Data + saves token to Keychain.
- `signIn` — fetches `Employee` matching email/password/role, then stores the token.
- `autoLogin` — restores the session from the Keychain on app restart.

### Theme (`Core/Theme/AppTheme.swift`)
- Shared `Color.appButtonGradient` (blue) backed by the `appPrimary` color asset — used consistently by every button in the app.

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 5.9+

## Notes

- Password is currently stored as plain text in Core Data — future improvement: hash before storing.
- The `Bug_Tracking_System.drawio` diagram describes the broader system design.
