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
│   │   ├── EquippedModifiers.swift # Aggregates equipped item modifiers; [LootItem] extension
│   │   ├── ItemModifier.swift      # Enum: AC/save/atk/dmg bonuses, ability score overrides
│   │   ├── LegendaryAction.swift
│   │   ├── MovementSpeed.swift
│   │   ├── RollEntry.swift         # Roll history record (type, name, roll, modifier, total, timestamp)
│   │   ├── SavingThrowProficiencies.swift
│   │   ├── Senses.swift
│   │   ├── SidebarItem.swift
│   │   ├── SkillProficiency.swift
│   │   ├── SpecialAbility.swift
│   │   ├── SpellSlot.swift         # Includes Int.romanNumeral extension
│   │   └── StatusCondition.swift
│   └── Entities/                   # Concrete entity models
│       ├── Combatent.swift
│       ├── CombatParticipant.swift
│       ├── InventoryItem.swift     # Per-entity inventory slot (lootItemID + isEquipped)
│       ├── LootItem.swift          # Wiki loot entry with structured `modifiers: [ItemModifier]`
│       ├── Monster.swift
│       ├── NPC.swift
│       ├── PlayerCharacter.swift
│       ├── SpellEntry.swift        # Wiki spell entry (level, school, casting time, etc.)
│       └── WikiEntry.swift         # Wiki rules entry with aliases for inline linking
├── Services/
│   ├── CampaignDataService.swift   # Entity lookup, combatent factory, initiative rolls
│   └── DemoData/                   # Hardcoded demo data (no persistence yet)
│       ├── CombatentData.swift
│       ├── LootData.swift
│       ├── MonsterData.swift
│       ├── NPCData.swift
│       ├── PlayerData.swift
│       ├── SidebarData.swift
│       ├── SpellData.swift
│       ├── StatusData.swift
│       └── WikiData.swift
├── ViewModels/
│   └── CampaignViewModel.swift     # @Observable root view model; all UI state & business logic
└── Views/
    ├── CampaignRootView.swift      # NavigationSplitView root
    ├── CampaignDetailPane.swift    # Detail pane content switcher
    ├── CampaignToolbar.swift       # ToolbarContent for Long Rest, Statuses, Add, Search, Roll History
    ├── CharacterCreationView.swift # Sheet form for building a new PlayerCharacter
    ├── RollHistoryInspectorView.swift # Right-side inspector showing the roll log (auto-scrolls)
    ├── SearchOverlayView.swift     # Cmd+F-style overlay for searching all entities
    ├── WikiEntryCreationView.swift # Sheet form for adding a new wiki entry
    ├── Common/                     # Reusable layout components (<100 lines each)
    │   ├── AbilityScoreCell.swift  # Highlights cells modified by equipment
    │   ├── AbilityScoresView.swift # Accepts `modifiedAbilities: Set<String>`
    │   ├── ActionsView.swift
    │   ├── CreatureSummaryGrid.swift # Accepts `acBonus: Int` for equipped AC bonuses
    │   ├── DescriptionRow.swift
    │   ├── DetailHeader.swift
    │   ├── DetailSection.swift
    │   ├── InventorySection.swift  # Inventory list with equip toggle and modifier display
    │   ├── LegendaryActionsView.swift
    │   ├── SkillsView.swift        # Skill proficiencies with rollable bonuses
    │   ├── SpecialAbilitiesView.swift
    │   ├── SpellSlotsView.swift    # Pip rows prefixed with Roman numeral level labels
    │   ├── StatValueRow.swift
    │   ├── StatusEditorRow.swift
    │   ├── StatusesView.swift
    │   ├── SummaryMetric.swift
    │   └── WikiLinkedText.swift    # Auto-detects wiki terms in text and renders as links
    ├── Detail/                     # Full stat-block detail views
    │   ├── CombatentDetailView.swift
    │   ├── InitiativeSelectionDetailView.swift
    │   ├── LootDetailView.swift
    │   ├── MonsterDetailView.swift
    │   ├── NPCDetailView.swift
    │   ├── PlayerCharacterDetailView.swift
    │   ├── SpellDetailView.swift
    │   └── WikiDetailView.swift
    ├── Initiative/                 # Initiative tracker components
    │   ├── InitiativeCard.swift
    │   ├── InitiativeEditorView.swift
    │   ├── InitiativeTrackerStrip.swift
    │   └── StatusPaletteView.swift
    └── Sidebar/
        └── CampaignSidebar.swift   # Custom DisclosureGroup-based sidebar (double-click to expand)
```

### State Management

`CampaignViewModel` (`@Observable`, `@MainActor`) is the single source of truth for the campaign screen. It owns:

**Selection / sheets / overlays:**
- `selectedItemID: String?` — sidebar selection
- `selectedInitiativeCombatentID: Combatent.ID?` — selected tracker card
- `editingCombatentID: Combatent.ID?` — triggers editor sheet
- `isStatusPalettePresented: Bool` & `pendingStatus: StatusCondition?` — status assignment flow
- `isLongRestConfirmationPresented: Bool`
- `isCharacterCreationPresented: Bool` — drives `CharacterCreationView`
- `isWikiEntryCreationPresented: Bool` — drives `WikiEntryCreationView`
- `isSearchPresented: Bool` & `searchQuery: String` — drives `SearchOverlayView`
- `isRollHistoryPresented: Bool` — toggles right-side `RollHistoryInspectorView`

**Live data:**
- `combatents: [Combatent]` — live initiative tracker entries
- `wikiEntries: [WikiEntry]` — wiki rules entries (mutable; `createWikiEntry(_:)` appends)
- `lootItems: [LootItem]` — wiki loot entries (with structured `modifiers`)
- `spellEntries: [SpellEntry]` — wiki spell entries
- `rollHistory: [RollEntry]` — append-at-front log of all rolls
- `playerInventories: [UUID: [InventoryItem]]` — per-player inventory keyed by player ID
- `monsterInventories: [UUID: [InventoryItem]]` — per-monster inventory
- `npcInventories: [UUID: [InventoryItem]]` — per-NPC inventory

The init pre-populates demo inventories for the first few players (e.g. wizard with Ring of Protection equipped) and a couple of NPCs.

Views observe the view model via `@Bindable` (for bindings) or plain property access (for reads). The view model delegates entity lookups and combatent creation to `CampaignDataService`.

### Models

Shared enums:
- `DamageType` — slashing, fire, necrotic, etc.
- `CreatureSize` — Tiny … Gargantuan
- `CreatureType` — Aberration, Beast, Dragon, etc.
- `Alignment` — Lawful Good … Unaligned
- `ItemModifier` — `.acBonus`, `.savingThrowBonus`, `.attackBonus`, `.damageBonus`, `.setAbilityScore(String, Int)` (with `displayText`)

Entity types:

| Type | Purpose |
|---|---|
| `PlayerCharacter` | Full player stats (race, class, level, HP, spell slots, actions, abilities) |
| `Monster` | Full stat block with CR, XP, legendary actions, damage modifiers |
| `NPC` | Named character with biography, role, spell slots, and combat stats |
| `Combatent` | Lightweight initiative-tracker row (name, HP, initiative, status, spell slots) |
| `WikiEntry` | Rules glossary entry: id, title, description, optional aliases for matching |
| `LootItem` | Magic item: id, name, type, rarity, description, properties, structured `modifiers` |
| `SpellEntry` | Spell: name, level (0 = cantrip), school, casting time, range, components, duration, description, concentration/ritual flags |
| `InventoryItem` | Inventory slot: random `UUID` + `lootItemID` + `isEquipped` |
| `RollEntry` | Roll log row: type, name, roll, modifier, total, timestamp |

`Combatent` is intentionally separate from the full entity types — it carries only the fields needed for the tracker strip. Note the existing misspelling (`Combatent` vs `Combatant`) — match it in new code to avoid compile errors.

`CombatParticipant` protocol (`Identifiable` with `UUID`) abstracts the common fields across `PlayerCharacter`, `Monster`, and `NPC` (name, current/max HP, ability scores, status, spell slots). `Monster` provides `[]` for `spellSlots` via a default extension.

Core structs:
- `AbilityScores` — STR/DEX/CON/INT/WIS/CHA with computed modifiers
- `MovementSpeed` — walk, optional swim/fly/climb/burrow, hover flag
- `Senses` — darkvision, blindsight, tremorsense, truesight, passive perception
- `Attack` — to-hit action with reach, damage roll, and damage type
- `SpecialAbility` — passive trait or feature description
- `LegendaryAction` — name, cost, and description
- `SpellSlot` — count and level. The file also extends `Int` with `.romanNumeral` (used by spell-slot UI and spell levels).
- `StatusCondition` — name, short effect, and longer description
- `SidebarItem` — recursive tree node for sidebar navigation (`id`, `title`, `systemImage`, `children`)
- `EquippedModifiers` — aggregates AC/save/atk/dmg bonuses + ability-score overrides; provides `effectiveScores(base:)`, `effectiveAC(base:)`, and `modifiedAbilityKeys`. `Array<LootItem>.equippedModifiers(for: [InventoryItem])` builds it from inventory.

### Inventory & Equipment

Each entity type (Player / Monster / NPC) has its inventory stored on the view model in `[UUID: [InventoryItem]]` dictionaries (keyed by entity ID). This keeps inventory state observable without modifying the entity structs themselves.

When an item is equipped, its `LootItem.modifiers` are aggregated into an `EquippedModifiers` value that detail views use to:
- Add `acBonus` to displayed AC (shown in `CreatureSummaryGrid` as e.g. `13 Dexterity (+1 eq.)`)
- Override ability scores in `AbilityScoresView` (modified cells highlighted with an accent sparkle and border)
- Surface `savingThrowBonus` / `attackBonus` / `damageBonus` (carried in the model; UI display can be expanded as needed)

Toggle equip state via `viewModel.toggleEquip(inventoryItemID:forEntity:entityType:)` where `entityType` is the `InventoryEntityType` enum (`.player` / `.monster` / `.npc`). The reusable `InventorySection` view renders the inventory list with an equip/unequip shield button and lists active modifiers in green when equipped.

### Services

`CampaignDataService` is a singleton (nonisolated) that provides:
- Entity lookup by sidebar ID (`player(for:)`, `monster(for:)`, `npc(for:)`, `wikiEntry(for:)`)
- Recursive sidebar item search
- Combatent factory (`makeCombatent(from:)`)
- Initiative roll generation (`rolledInitiative(for:)` and `initiativeRoll(for:)` for logged rolls)

Demo data lives in `Services/DemoData/` as global constants. `testPlayers` is declared as `var` so `longRest()` and `createPlayerCharacter(_:)` can mutate it. Wiki/loot/spell collections are owned by the view model (`wikiEntries`, `lootItems`, `spellEntries`) and seeded from their respective demo-data files. No persistence or networking exists yet.

### Views

**Root:** `CampaignRootView` sets up the `NavigationSplitView` with `CampaignSidebar` and the detail area. The detail area shows `InitiativeTrackerStrip` (always visible) above `CampaignDetailPane`, with an optional `RollHistoryInspectorView` on the right when toggled.

**Sidebar:** `CampaignSidebar` is a custom recursive tree built on `DisclosureGroup` (not `List(children:)`
) so it can own expansion state explicitly. Double-clicking any folder label toggles its expanded state, in addition to the standard disclosure-arrow click. Items remain draggable for the initiative tracker.

**Sidebar tree** (built dynamically by `CampaignViewModel.sidebarItems`):
- `Players` — one row per `PlayerCharacter`
- `NPCs` → `Monsters` / `Characters` / `Other`
- `Public Assets`, `Private Assets` (placeholders)
- `Wiki`
  - `Entries` — rules glossary
  - `Loot` — magic items
  - `Spells` — grouped into `Cantrips`, `Level I`, `Level II`, … using Roman numerals (built by the private `spellSidebarGroups()` helper)

**Initiative Tracker:** `InitiativeTrackerStrip` is a horizontal scroll of `InitiativeCard` views. Supports:
- Drag-to-add from sidebar (creates a `Combatent` via `CampaignDataService`; logs the initiative roll)
- Drag-to-assign statuses (payload prefix: `status:`)
- Tap-to-select (or assign a queued status)
- Long-press / secondary-click → `InitiativeEditorView` sheet

**Detail Pane:** `CampaignDetailPane` switches between:
- `InitiativeSelectionDetailView` (delegates to linked player/monster/NPC detail, or falls back to `CombatentDetailView`)
- `PlayerCharacterDetailView` / `MonsterDetailView` / `NPCDetailView` for sidebar selections — each receives `inventory`, `allLoot`, and an `onToggleEquip` callback so equipment modifiers flow into the displayed stats
- `WikiDetailView` / `LootDetailView` / `SpellDetailView` for wiki sidebar items
- Placeholder for non-entity sidebar items

The pane sets two environment values: `\.wikiEntries` (used by `WikiLinkedText` to detect glossary terms) and `\.navigateToWikiEntry` (so any inline wiki link can switch the sidebar selection).

**Toolbar:** `CampaignToolbar` (`ToolbarContent`) provides:
- **Long Rest** — resets all combatants' and players' HP and clears statuses (after confirmation)
- **Statuses** — opens `StatusPaletteView` popover to queue or drag statuses
- **Add** menu — opens `CharacterCreationView` to add a player or `WikiEntryCreationView` to add a wiki entry
- **Search** — opens `SearchOverlayView`
- **Roll History** — toggles the `RollHistoryInspectorView` panel

**Roll History:** `RollHistoryInspectorView` displays `viewModel.rollHistory` (newest at top). It uses a `ScrollViewReader` with a hidden bottom anchor and animates a scroll on every count change so newly added rolls are always visible.

**Search:** `SearchOverlayView` searches across players, monsters, NPCs, wiki entries, loot, and spells — clicking a result selects the corresponding sidebar item.

**Character Creation:** `CharacterCreationView` is a form-based sheet that builds a `PlayerCharacter` and hands it back via an `onSave` closure. `CampaignRootView` wires the closure to `CampaignViewModel.createPlayerCharacter(_:)`.

**Wiki Entry Creation:** `WikiEntryCreationView` is a form-based sheet for adding a new `WikiEntry`. The view model's `createWikiEntry(_:)` ensures unique IDs by appending `-2`, `-3`, etc. on collision.

### Demo Data

Global constants in `Services/DemoData/`:
- `testMonsters: [Monster]` — 10 creatures (Goblin, Orc, Troll, Beholder, Adult Red Dragon, Gelatinous Cube, Mimic, Skeleton, Zombie, Owlbear)
- `testNPCs: [NPC]` — 5 characters (Guard Captain, Merchant, Archmage, Mayor, Barkeep)
- `testPlayers: [PlayerCharacter]` — 4 players (Wizard, Barbarian, Warlock, Paladin). Declared as `var` so `longRest()` and `createPlayerCharacter(_:)` can mutate it.
- `testCombatents: [Combatent]` — 7 prebuilt tracker rows (Ranger, Cleric, Fighter, Guard Captain, Ogre, Goblin Archer, Young Wyvern)
- `wikiDemoData: [WikiEntry]` — ~12 rules entries (Advantage, Disadvantage, Concentration, etc.) seeded into the view model
- `lootDemoData: [LootItem]` — 10 magic items; items with structured `modifiers` include Ring of Protection, Gauntlets of Ogre Power, Amulet of Health, Sword of Vengeance, Dwarven Thrower
- `spellDemoData: [SpellEntry]` — 16 spells across all levels (cantrips through 9th)
- `sidebarItems: [SidebarItem]` — legacy static tree (the live tree is computed by `CampaignViewModel.sidebarItems`)

No persistence or networking exists yet.

### Test Frameworks

- **Unit tests** (`DnDAppSwiftUITests/`) use the Swift Testing framework (`import Testing`, `@Test` macro, `#expect()`).
- **UI tests** (`DnDAppSwiftUIUITests/`) use XCTest.
