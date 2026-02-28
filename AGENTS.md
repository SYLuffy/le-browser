# AGENTS.md

## Project Overview

**Lettuce Browser** (le-browser) is a native iOS mobile web browser with an integrated VPN (LBFlashVPN). It is written in Objective-C (primary) and Swift, built with Xcode, and uses CocoaPods for dependency management.

### Targets
- **Lettuce Browser** — Main browser app (Objective-C + Swift)
- **LBFlashVPN** — Network Extension (Packet Tunnel Provider) for VPN functionality (Swift)

### Dependencies
- Managed via CocoaPods (`Podfile`). The `Pods/` directory is committed to the repo.
- Run `pod install` from the repo root to refresh dependencies.

## Cursor Cloud specific instructions

### Platform constraint
This is an **iOS-only project** that requires **macOS + Xcode** to build, run, and execute automated tests (XCTest). The project **cannot be compiled or run on Linux**. There are no test targets defined in the Xcode project.

### What works on Linux (Cursor Cloud VM)
- **CocoaPods dependency resolution**: `pod install` works and validates the Podfile/dependency graph (Ruby + CocoaPods must be installed).
- **SwiftLint**: Lint the Swift source files with:
  ```
  swiftlint lint "Lettuce Browser" "LBFlashVPN"
  ```
  Requires Swift toolchain in PATH (`/usr/local/usr/bin`). SwiftLint binary is at `/usr/local/bin/swiftlint`.
- **File structure validation**: All 111 source files (105 in Lettuce Browser, 6 in LBFlashVPN) can be inspected and reviewed.

### What does NOT work on Linux
- `xcodebuild` — not available, cannot compile the project.
- iOS Simulator — not available, cannot run the app.
- XCTest / automated tests — no test targets exist, and even if they did, they would require Xcode.
- `cppcheck` on Objective-C — reports false syntax errors due to ObjC message-passing syntax.

### Key paths
- App source: `Lettuce Browser/` (Objective-C + Swift)
- VPN extension source: `LBFlashVPN/` (Swift + Objective-C)
- Xcode workspace: `Lettuce Browser.xcworkspace` (use this, not the `.xcodeproj`)
- CocoaPods config: `Podfile`, `Podfile.lock`, `Pods/`
- Firebase configs: `Lettuce Browser/Debug - FirebaseInfo/`, `Lettuce Browser/Pro - FirebaseInfo/`
- Ad configs: `Lettuce Browser/admob_debug.json`, `Lettuce Browser/admob_pro.json`

### Lint command
```
swiftlint lint "Lettuce Browser" "LBFlashVPN"
```
Exit code 2 indicates lint violations found (325 warnings/10 errors in current codebase — these are pre-existing). Exit code 0 means clean.

### Build command (macOS only)
```
xcodebuild -workspace "Lettuce Browser.xcworkspace" -scheme "Lettuce Browser" -sdk iphonesimulator build
```
