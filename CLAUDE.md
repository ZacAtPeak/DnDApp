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

The app follows MVVM with `@Observable` state management and a lightweight service layer.

### Directory Layout

```
DnDAppSwiftUI/
├── DnDAppSwiftUIApp.swift          # App entry point; window size
├── ContentView.swift               # Thin shim → CampaignRootView
├── Models/
│   ├── GameMechanics/              # Shared enums & value types
│   │   ├── AbilityScores.swift
│   │   ├── Alignment.swift
│   │   ├── Attack.swift
│   │   ├── CreatureSize.swift
│   │   ├── CreatureType.swift
│   │   ├── DamageType.swift
│   │   ├── LegendaryAction.swift
│   │   ├── MovementSpeed.swift
│   │   ├── SavingThrowProficiencies.swift
│   │   ├── Senses.swift
│   │   ├── SidebarItem.swift
│   │   ├── SkillProficiency.swift
│   │   ├── SpecialAbility.swift
│   │   ├── SpellSlot.swift
│   │   └── StatusCondition.swift
│   └── Entities/                   # Concrete entity models
│       ├── Combatent.swift
│       ├── CombatParticipant.swift
│       ├── Monster.swift
│       ├── NPC.swift
│       └── PlayerCharacter.swift
├── Services/
│   ├── CampaignDataService.swift   # Entity lookup, combatent factory, initiative rolls
│   └── DemoData/                   # Hardcoded demo data (no persistence yet)
│       ├── CombatentData.swift
│       ├── MonsterData.swift
│       ├── NPCData.swift
│       ├── PlayerData.swift
│       ├── SidebarData.swift
│       └── StatusData.swift
├── ViewModels/
│   └── CampaignViewModel.swift     # @Observable root view model; all UI state & business logic
└── Views/
    ├── CampaignRootView.swift      # NavigationSplitView root
    ├── CampaignDetailPane.swift    # Detail pane content switcher
    ├── CampaignToolbar.swift       # ToolbarContent for Long Rest, Statuses, Add
    ├── CharacterCreationView.swift # Sheet form for building a new PlayerCharacter
    ├── Common/                     # Reusable layout components (<100 lines each)
    │   ├── AbilityScoreCell.swift
    │   ├── AbilityScoresView.swift
    │   ├── ActionsView.swift
    │   ├── CreatureSummaryGrid.swift
    │   ├── DescriptionRow.swift
    │   ├── DetailHeader.swift
    │   ├── DetailSection.swift
    │   ├── LegendaryActionsView.swift
    │   ├── SpecialAbilitiesView.swift
    │   ├── SpellSlotsView.swift
    │   ├── StatValueRow.swift
    │   ├── StatusEditorRow.swift
    │   ├── StatusesView.swift
    │   └── SummaryMetric.swift
    ├── Detail/                     # Full stat-block detail views
    │   ├── CombatentDetailView.swift
    │   ├── InitiativeSelectionDetailView.swift
    │   ├── MonsterDetailView.swift
    │   ├── NPCDetailView.swift
    │   └── PlayerCharacterDetailView.swift
    ├── Initiative/                 # Initiative tracker components
    │   ├── InitiativeCard.swift
    │   ├── InitiativeEditorView.swift
    │   ├── InitiativeTrackerStrip.swift
    │   └── StatusPaletteView.swift
    └── Sidebar/
        └── CampaignSidebar.swift   # Sidebar list with draggable items
```

### State Management

`CampaignViewModel` (`@Observable`, `@MainActor`) is the single source of truth for the campaign screen. It owns:
- `selectedItemID: String?` — sidebar selection
- `combatents: [Combatent]` — live initiative tracker entries
- `selectedInitiativeCombatentID: Combatent.ID?` — selected tracker card
- `editingCombatentID: Combatent.ID?` — triggers editor sheet
- `isStatusPalettePresented: Bool` & `pendingStatus: StatusCondition?` — status assignment flow
- `isCharacterCreationPresented: Bool` — drives the `CharacterCreationView` sheet; `createPlayerCharacter(_:)` appends the result to `testPlayers` and rebuilds the sidebar

Views observe the view model via `@Bindable` (for bindings) or plain property access (for reads). The view model delegates data lookups and combatent creation to `CampaignDataService`.

### Models

Shared enums:
- `DamageType` — slashing, fire, necrotic, etc.
- `CreatureSize` — Tiny … Gargantuan
- `CreatureType` — Aberration, Beast, Dragon, etc.
- `Alignment` — Lawful Good … Unaligned

Entity types:

| Type | Purpose |
|---|---|
| `PlayerCharacter` | Full player stats (race, class, level, HP, spell slots, actions, abilities) |
| `Monster` | Full stat block with CR, XP, legendary actions, damage modifiers |
| `NPC` | Named character with biography, role, spell slots, and combat stats |
| `Combatent` | Lightweight initiative-tracker row (name, HP, initiative, status, spell slots) |

`Combatent` is intentionally separate from the full entity types — it carries only the fields needed for the tracker strip. Note the existing misspelling (`Combatent` vs `Combatant`) — match it in new code to avoid compile errors.

`CombatParticipant` protocol (`Identifiable` with `UUID`) abstracts the common fields across `PlayerCharacter`, `Monster`, and `NPC` (name, current/max HP, ability scores, status, spell slot count). It is used by `CampaignDataService.makeCombatent(from:)` and `rolledInitiative(for:)`.

Core structs:
- `AbilityScores` — STR/DEX/CON/INT/WIS/CHA with computed modifiers
- `MovementSpeed` — walk, optional swim/fly/climb/burrow, hover flag
- `Senses` — darkvision, blindsight, tremorsense, truesight, passive perception
- `Attack` — to-hit action with reach, damage roll, and damage type
- `SpecialAbility` — passive trait or feature description
- `LegendaryAction` — name, cost, and description
- `SpellSlot` — count and level
- `StatusCondition` — name, short effect, and longer description
- `SidebarItem` — recursive tree node for sidebar navigation (`id`, `title`, `systemImage`, `children`)

### Services

`CampaignDataService` is a singleton (nonisolated) that provides:
- Entity lookup by sidebar ID (`player(for:)`, `monster(for:)`, `npc(for:)`)
- Recursive sidebar item search
- Combatent factory (`makeCombatent(from:)`)
- Initiative roll generation (`rolledInitiative(for:)`)

All demo data lives in `Services/DemoData/` as global constants (`testMonsters`, `testNPCs`, `testPlayers`, `testCombatents`, `sidebarItems`, `defaultStatusConditions`). `testPlayers` is declared as `var` so `longRest()` and `createPlayerCharacter(_:)` can mutate it. No persistence or networking exists yet.

### Views

**Root:** `CampaignRootView` sets up the `NavigationSplitView` with `CampaignSidebar` and the detail area. The detail area shows `InitiativeTrackerStrip` (always visible) above `CampaignDetailPane`.

**Initiative Tracker:** `InitiativeTrackerStrip` is a horizontal scroll of `InitiativeCard` views. Supports:
- Drag-to-add from sidebar (creates a `Combatent` via `CampaignDataService`)
- Drag-to-assign statuses (payload prefix: `status:`)
- Tap-to-select (or assign a queued status)
- Long-press / secondary-click → `InitiativeEditorView` sheet

**Detail Pane:** `CampaignDetailPane` switches between:
- `InitiativeSelectionDetailView` (delegates to linked player/monster/NPC detail, or falls back to `CombatentDetailView`)
- `PlayerCharacterDetailView` / `MonsterDetailView` / `NPCDetailView` for sidebar selections
- Placeholder for non-entity sidebar items

**Toolbar:** `CampaignToolbar` (`ToolbarContent`) provides:
- **Long Rest** — resets all combatants' and players' HP and clears statuses
- **Statuses** — opens `StatusPaletteView` popover to queue or drag statuses
- **Add** menu — opens `CharacterCreationView` to add a new player character (other entries still placeholders)

**Character Creation:** `CharacterCreationView` is a form-based sheet (presented from the toolbar Add menu) that builds a `PlayerCharacter` and hands it back via an `onSave` closure. `CampaignRootView` wires the closure to `CampaignViewModel.createPlayerCharacter(_:)`.

### Demo Data

Global constants in `Services/DemoData/`:
- `testMonsters: [Monster]` — 10 creatures (Goblin, Orc, Troll, Beholder, Adult Red Dragon, Gelatinous Cube, Mimic, Skeleton, Zombie, Owlbear)
- `testNPCs: [NPC]` — 5 characters (Guard Captain, Merchant, Archmage, Mayor, Barkeep)
- `testPlayers: [PlayerCharacter]` — 4 players (Wizard, Barbarian, Warlock, Paladin). Declared as `var` so `longRest()` and `createPlayerCharacter(_:)` can mutate it.
- `testCombatents: [Combatent]` — 7 prebuilt tracker rows (Ranger, Cleric, Fighter, Guard Captain, Ogre, Goblin Archer, Young Wyvern)
- `sidebarItems: [SidebarItem]` — static tree built from the above collections

No persistence or networking exists yet.

### Test Frameworks

- **Unit tests** (`DnDAppSwiftUITests/`) use the Swift Testing framework (`import Testing`, `@Test` macro, `#expect()`).
- **UI tests** (`DnDAppSwiftUIUITests/`) use XCTest.
