# 📋 Contribution Log — Sahaj Srivastava
**Role:** Project Admin · Frontend Developer  
**Project:** SchoolSync — SW2627-Dart-Flutter-Firebase-SchoolSync  

---

### 🎯 Objective
Set up the Flutter development environment, validate the project scaffold, resolve build blockers, and get the app running on a web target for the first time.

---

### ✅ Tasks Completed

#### 1. 🔧 Flutter Environment Audit
- Conducted a full `flutter doctor -v` diagnostic on the local machine
- Verified Flutter SDK (v3.44.9, stable channel) installed correctly at `D:\development\flutter`
- Confirmed `D:\development\flutter\bin` is correctly added to system `PATH`
- Identified and documented all environment issues hindering Android development

#### 2. 🐛 Fixed Critical Bug in `lib/main.dart`
- Identified two compile-breaking syntax errors caused by missing class name prefixes in Dart
- **Fix 1 (Line 31):** Corrected `.fromSeed(...)` → `ColorScheme.fromSeed(...)`
- **Fix 2 (Line 105):** Corrected `.center` → `MainAxisAlignment.center`
- App was completely non-compilable before this fix

#### 3. 🔓 Resolved OneDrive File-Locking Issue
- Diagnosed that project stored under `OneDrive\Desktop\` caused OneDrive to place **reparse-point locks** on Flutter's ephemeral build directories
- Locked paths identified:
  - `ios/Flutter/ephemeral/Packages/`
  - `macos/Flutter/ephemeral/Packages/`
- Force-removed all locked directories using `rd /s /q` to restore Flutter's read/write access

#### 4. 🌐 Successfully Ran App on Chrome (Web Target)
- Executed `flutter run -d chrome` successfully
- Dart VM connected at `ws://127.0.0.1:53711/`
- Flutter DevTools profiler & debugger confirmed live
- App launched in Chrome debug mode — Flutter counter scaffold confirmed working

#### 5. 📁 Initialized Flutter Project Scaffold (`mobile_app/`)
- Verified the generated Flutter project structure:
  - `lib/main.dart` — app entry point ✅
  - `pubspec.yaml` — dependency manifest ✅
  - `android/`, `ios/`, `web/`, `windows/` platform folders ✅
  - `pubspec.lock` present for dependency consistency across team ✅
- Confirmed `.gitignore` covers all Flutter build artifacts and IDE files

---

### ⚠️ Blockers Identified & Documented

| Blocker | Status | Owner |
|---|---|---|
| Android Studio not installed — cannot build for Android | 🔴 Open | Sahaj (self) |
| `ANDROID_HOME` / `ANDROID_SDK_ROOT` env vars not set | 🔴 Open | Sahaj (self) |
| `JAVA_HOME` not set; Java 8 installed (need Java 17) | 🟡 Open | Sahaj (self) |
| Project on OneDrive path (causes recurring file locks) | 🟡 Open | Sahaj (self) |
| `mobile_app/` not yet committed/pushed to GitHub | 🟡 Open | Sahaj (self) |

---

### 📝 Notes & Decisions

- **Web-first approach adopted for Day 1:** Since Android toolchain is not yet set up, `flutter run -d chrome` was used as the primary testing target. All UI work can proceed via Chrome until Android Studio is installed.
- **`google-services.json` must be added to `.gitignore`** before Firebase integration begins — flagged for the team.
- **Architecture doc reviewed:** The `docs/architecture.md` feature-first folder structure is approved and will be used as the blueprint for `lib/` directory creation.

---

### 🔗 References
- [`lib/main.dart`](../mobile_app/lib/main.dart) — Bug fixes applied
- [`pubspec.yaml`](../mobile_app/pubspec.yaml) — Dependency manifest
- [`docs/architecture.md`](./architecture.md) — Folder structure blueprint
- [Flutter Setup Audit Report](./flutter_audit_report.md) — Full environment audit

---

## 📅 2026-08-19 — Dashboard Screen & Team Sync

### 🎯 Objective
Build the district admin dashboard screen with reusable Flutter widgets, integrate it with the Firebase-backed `DashboardService`, and sync the local branch with the latest `origin/main` to incorporate team changes (models, seed data, and backend services).

---

### ✅ Tasks Completed

#### 1. 🎨 Dashboard Screen & Widgets
- Created `DashboardScreen` as the app's new home route with `FutureBuilder` + `RefreshIndicator`
- Implemented 30-second auto-refresh `Timer` for live data updates
- Built `DashboardHeader` — district admin label, live sync badge, and user avatar with initials
- Built `StatCard` — semi-circular gauge painter for attendance/fees; arrow variant for exam status
- Built `SchoolCard` — school summary tile with student count, attendance %, and status badges
- Built `DashboardBottomNav` — floating pill navigation bar with 4 tabs (Board, Attendance, Fees, Exams)

#### 2. 🎨 Design System
- Created `AppColors` utility class with project-specific palette
- Applied consistent spacing, shadows, and border tokens across all dashboard widgets

#### 3. 🔄 Routing & Firebase Integration
- Updated `main.dart` home route to `DashboardScreen`
- Integrated Firebase initialization with `DefaultFirebaseOptions` and conditional seed data flag
- Wired dashboard to consume `DashboardService.getDistrictSummary()` with fallback data

#### 4. 🔀 Branch Sync
- Pulled latest `origin/main` (7 commits ahead, fast-forward from `15049cb` → `0b8d8a2`)
- Merged upstream changes including:
  - Seed data for testing (`seeddata.dart`)
  - Login/signup models and auth service updates
  - Platform folder cleanup (removed ios, linux, macos, web, windows build artifacts)

---

### 📊 Code Stats
| Metric | Count |
|--------|-------|
| Files Added | 6 |
| Files Modified | 2 (`main.dart`, existing routing) |
| Lines Added | ~430 |
| Widgets Created | 4 |
| Services Integrated | 1 (`DashboardService`) |

---

### ⚠️ Blockers & Next Steps

| Blocker / Next Step | Status | Owner |
|---|---|---|
| Bottom nav tap handlers not yet wired to screen routing | 🟡 Open | Sahaj (self) |
| Web platform folders deleted upstream; need `flutter create .` to restore | 🟡 Open | Sahaj (self) |
| Firebase collection rules need review before production | 🟡 Open | Team |

---

### 📝 Notes & Decisions

- **Widget-first architecture:** Dashboard broken into single-responsibility widgets for maintainability and hot-reload friendliness.
- **Firebase-first data flow:** `DashboardService` handles all aggregation server-side; UI remains stateless and reactive via `FutureBuilder`.
- **Fallback strategy:** `_getFallbackSummary()` provides hardcoded seed data when Firestore queries fail, ensuring UI is always reviewable.
- **Team sync:** Merged Kavya Kakkar's `DashboardService` + models and Aayaan's seed data to keep feature branch current.

---

### 🔗 References
- [`dashboard_screen.dart`](../mobile_app/lib/screens/dashboard_screen.dart)
- [`dashboard_header.dart`](../mobile_app/lib/widgets/dashboard_header.dart)
- [`school_card.dart`](../mobile_app/lib/widgets/school_card.dart)
- [`stat_card.dart`](../mobile_app/lib/widgets/stat_card.dart)
- [`dashboard_bottom_nav.dart`](../mobile_app/lib/widgets/dashboard_bottom_nav.dart)
- [`app_colors.dart`](../mobile_app/lib/utils/app_colors.dart)
- [`dashboard_service.dart`](../mobile_app/lib/services/dashboard_service.dart)

---

*Log maintained by Sahaj Srivastava · Updated after each working session*
