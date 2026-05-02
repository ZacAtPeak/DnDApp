# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

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

The main application source is in `DnDAppSwiftUI/`:

- **`DnDAppSwiftUI/DnDAppSwiftUIApp.swift`** — App entry point; sets the default window size.
- **`DnDAppSwiftUI/ContentView.swift`** — Root view with `NavigationSplitView`, initiative tracker, and all detail views.
- **`DnDAppSwiftUI/Models.swift`** — All data models, enums, protocols, and hardcoded demo data.

### Layout

`ContentView` uses `NavigationSplitView` with a sidebar and a detail pane.

**Sidebar** (`List` with recursive `children` via `SidebarItem`) contains:
- Players (`person.2`) with children mapped from `testPlayers` (IDs: `player-<UUID>`)
- NPCs (`person.3`) with nested groups:
  - Monsters (IDs: `monster-<UUID>`)
  - Characters (IDs: `character-<UUID>`)
  - Other
- Public Assets & Private Assets

Sidebar items are draggable. Dragging a player, monster, or NPC into the initiative tracker creates a `Combatent` for that entity.

**Detail Pane** always shows:
1. **Initiative Tracker** — horizontal scroll of `InitiativeCard` views at the top. Supports drag-to-add from sidebar, drag-to-assign statuses, tap-to-select, and long-press/secondary-click to edit.
2. **Selected Content** below the tracker:
   - `InitiativeSelectionDetailView` when an initiative card is selected (delegates to player/monster/NPC detail views, or falls back to `CombatentDetailView`)
   - `PlayerCharacterDetailView`, `MonsterDetailView`, or `NPCDetailView` when a sidebar item is selected
   - Placeholder for non-entity sidebar items

Toolbar buttons:
- **Long Rest** — resets all combatants' and players' HP and clears statuses
- **Statuses** — opens a `StatusPaletteView` popover to queue or drag statuses
- **Add** menu — placeholder for adding characters, assets, or statuses

### State Management

`ContentView` holds the following `@State`:
- `selectedItemID: String?` — current sidebar selection
- `combatents: [Combatent]` — live initiative tracker entries
- `selectedInitiativeCombatentID: Combatent.ID?` — selected initiative card
- `editingCombatentID: Combatent.ID?` — triggers the `InitiativeEditorView` sheet
- `isStatusPalettePresented: Bool` — status palette popover visibility
- `pendingStatus: StatusCondition?` — queued status awaiting assignment via card tap

Initiative cards support:
- `dropDestination` for status drag payloads (prefix: `status:`)
- `contextMenu` with Edit action
- `onLongPressGesture` to open the editor

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

`CombatParticipant` protocol (`Identifiable` with `UUID`) abstracts the common fields across `PlayerCharacter`, `Monster`, and `NPC` (name, current/max HP, ability scores, status, spell slot count). It is used by `makeCombatent(from:)` and `rolledInitiative(for:)`.

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

### Views (ContentView.swift)

Major view components (all in `ContentView.swift`):
- `InitiativeCard` — card in the tracker strip showing name, initiative, HP, spell slots, and active statuses
- `InitiativeEditorView` — sheet for editing a combatant's name, HP, initiative, turn state, spell slots, and statuses
- `StatusPaletteView` — scrollable popover of assignable statuses, draggable onto initiative cards
- `PlayerCharacterDetailView` / `MonsterDetailView` / `NPCDetailView` — full stat block layouts
- `CombatentDetailView` — fallback detail for initiative-only combatants with no linked entity
- `CreatureSummaryGrid` — reusable grid of AC, hit dice, initiative, speed, senses, languages
- `AbilityScoresView` / `AbilityScoreCell` — six-score grid with modifiers
- `StatusesView` — list of active status conditions with descriptions
- `SpellSlotsView` — spell slot remaining or per-level breakdown
- `SpecialAbilitiesView` / `ActionsView` / `LegendaryActionsView` — description rows
- `DetailHeader` / `DetailSection` / `SummaryMetric` / `DescriptionRow` — layout primitives
- `StatValueRow` / `StatusEditorRow` — form rows for the initiative editor

### Demo Data

Global constants at the bottom of `Models.swift`:
- `testMonsters: [Monster]` — 10 creatures (Goblin, Orc, Troll, Beholder, Adult Red Dragon, Gelatinous Cube, Mimic, Skeleton, Zombie, Owlbear)
- `testNPCs: [NPC]` — 5 characters (Guard Captain, Merchant, Archmage, Mayor, Barkeep)
- `testPlayers: [PlayerCharacter]` — 4 players (Wizard, Barbarian, Warlock, Paladin). Declared as `var` so `longRest()` can mutate HP/status.
- `testCombatents: [Combatent]` — 7 prebuilt tracker rows (Ranger, Cleric, Fighter, Guard Captain, Ogre, Goblin Archer, Young Wyvern)
- `sidebarItems: [SidebarItem]` — static tree built from the above collections

No persistence or networking exists yet.

### Test Frameworks

- **Unit tests** (`DnDAppSwiftUITests/`) use the Swift Testing framework (`import Testing`, `@Test` macro, `#expect()`).
- **UI tests** (`DnDAppSwiftUIUITests/`) use XCTest.
