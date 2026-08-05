# Bug Tracking System

A bug tracking application built with **SwiftUI** and **Core Data** for iOS. Users sign up / log in by role (Project Manager, Developer, QA Tester), and session tokens are stored securely in the Keychain.

## Features

- Splash screen with animated entrance and 5-second timed navigation
- Authentication (Login / Sign Up) with role selection
- Secure token storage via Keychain (Security framework)
- User session management with `@Observable`
- Local persistence with Core Data

## Tech Stack

- **SwiftUI** — declarative UI
- **Core Data** — local data persistence (Employee, Bug, Comment, Project, Team entities)
- **Security / Keychain** — secure token storage
- **Swift Observation** (`@Observable`) — reactive session state

## Project Structure

```
BugTrackingSystem/
├── BugTrackingSystem.xcdatamodeld   # Core Data model
├── Model/
│   └── RoleEnum.swift               # Roles: Project Manager, Developer, QA Tester
├── View/
│   ├── SplashScreen/
│   │   └── SplashView.swift         # Splash with bounce animation + auto navigation
│   └── AuthScreen/
│       ├── AuthView.swift           # Login / Sign Up UI + role picker
│       ├── TopCardView.swift        # Header card with title/detail
│       └── CustomTextFieldView.swift# Reusable text field (secure/plain + icon)
├── Core/
│   ├── Session/
│   │   └── SessionManager.swift     # Singleton session state + sign up / sign in
│   ├── Helper/
│   │   └── KeyChainHelper.swift     # Keychain save / read / delete
│   └── Extension/
│       └── Extension.swift          # NSManagedObjectContext.saveData()
├── Persistence.swift                # NSPersistentContainer
├── ContentView.swift                # Switches Auth <-> main content
└── BugTrackingSystemApp.swift       # App entry
```

## Getting Started

1. Open `BugTrackingSystem.xcodeproj` in Xcode.
2. Select a simulator or device with iOS 17+.
3. Press **Run**.

## How It Works

### Flow
- App launches → `SplashView` (5s + bounce animation) → `ContentView`
- `ContentView` checks `SessionManager.shared.isLoggedIn`:
  - **Not logged in** → `AuthView` (Login / Sign Up)
  - **Logged in** → main content
- On login / sign up, a loading spinner is shown while the session is verified, then the view switches to the main content.
- On successful sign in, a token is saved to the Keychain; on app restart, the token's presence keeps the user logged in.

### Session (`SessionManager.swift`)
- Singleton (`SessionManager.shared`) using `@Observable`.
- `signUp` — saves token to Keychain, creates an `Employee` record in Core Data.
- `signIn` — fetches `Employee` matching `email` **and** `password`, then stores the token.

### Keychain (`KeyChainHelper.swift`)
- Wraps `Security` framework (`SecItemAdd`, `SecItemCopyMatching`, `SecItemDelete`).
- `save(key:value:)`, `read(key:)`, `delete(key:)` — generic password items.

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Notes

- Password is currently stored as plain text in Core Data — future improvement: hash before storing.
- The `Bug_Tracking_System.drawio` diagram describes the broader system design.
