# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A D&D session companion app built with SwiftUI targeting macOS, iOS, and visionOS (deployment target 26.4, Swift 5.0). The app is in early development — all data is currently hardcoded demo data with no persistence layer yet.

## Build & Run

Open `DnDAppSwiftUI.xcodeproj` in Xcode and run the `DnDAppSwiftUI` scheme. The app is sized for macOS at 1250×875 by default.

Command-line build:
```bash
xcodebuild -project DnDAppSwiftUI.xcodeproj -scheme DnDAppSwiftUI build
```

Run unit tests:
```bash
xcodebuild test -project DnDAppSwiftUI.xcodeproj -scheme DnDAppSwiftUITests
```

Run UI tests:
```bash
xcodebuild test -project DnDAppSwiftUI.xcodeproj -scheme DnDAppSwiftUIUITests
```

Run a single test (Swift Testing):
```bash
xcodebuild test -project DnDAppSwiftUI.xcodeproj -scheme DnDAppSwiftUITests -only-testing:DnDAppSwiftUITests/DnDAppSwiftUITests/exampleTest
```

## Architecture

The codebase is currently three files:

- **`DnDAppSwiftUI/DnDAppSwiftUIApp.swift`** — App entry point; sets the default window size.
- **`DnDAppSwiftUI/ContentView.swift`** — All UI views live here.
- **`DnDAppSwiftUI/Models.swift`** — All data models, enums, and hardcoded demo data.

### Layout

`ContentView` uses `NavigationSplitView` with a sidebar and a detail pane. The detail pane always shows the **Initiative Tracker** strip (horizontal scroll of `InitiativeCard` views) at the top, with the selected content below. Sidebar selection is tracked via `@State private var selectedItemID: String?`.

Player sidebar items are encoded as `"player-<UUID>"` strings; `ContentView.selectedPlayer` strips the prefix and looks up the player in `testPlayers`. Other sidebar items show placeholder text.

### Models

Three entity types represent combat participants:

| Type | Purpose |
|---|---|
| `PlayerCharacter` | Simplified player stats (HP, status, spell slots) |
| `Monster` | Full stat block with CR, legendary actions, damage modifiers |
| `NPC` | Named character with biography, role, and spell slots |
| `Combatent` | Lightweight combat-row model used only in the initiative tracker |

`Combatent` is intentionally separate from the full entity types — it carries only the fields needed for the tracker strip. Note the existing misspelling (`Combatent` vs `Combatant`) — match it in new code to avoid compile errors.

`statusCondition` (lowercase) and `SidebarItem` are shared utility types. `SidebarItem` supports recursive `children` for tree navigation in the sidebar list.

Demo data global constants (`testMonsters`, `testNPCs`, `testPlayers`, `testCombatents`, `sidebarItems`) are defined at the bottom of `Models.swift`. No persistence or networking exists yet.

### Test Frameworks

- **Unit tests** (`DnDAppSwiftUITests/`) use the Swift Testing framework (`import Testing`, `@Test` macro, `#expect()`).
- **UI tests** (`DnDAppSwiftUIUITests/`) use XCTest.
