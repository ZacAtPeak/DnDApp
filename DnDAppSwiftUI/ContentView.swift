//
//  ContentView.swift
//  DnDAppSwiftUI
//
//  Created by Zachary Reyes on 5/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItemID: String? = "players"
    @State private var combatents: [Combatent] = []
    @State private var selectedInitiativeCombatentID: Combatent.ID?
    @State private var isInitiativeTargeted = false
    @State private var editingCombatentID: Combatent.ID?
    @State private var isStatusPalettePresented = false
    @State private var pendingStatus: StatusCondition?

    private var sidebarSelection: Binding<String?> {
        Binding {
            selectedItemID
        } set: { newSelection in
            selectedItemID = newSelection
            selectedInitiativeCombatentID = nil
        }
    }

    private var isShowingCombatentEditor: Binding<Bool> {
        Binding {
            editingCombatentID != nil
        } set: { isShowing in
            if !isShowing {
                editingCombatentID = nil
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(sidebarItems, children: \.children, selection: sidebarSelection) { item in
                Label(item.title, systemImage: item.systemImage)
                    .draggable(item.id)
            }
            .navigationTitle("Navigation")
        } detail: {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Initiative Tracker")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .padding(.top)

                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 16) {
                                if combatents.isEmpty {
                                    Text("Drag characters here to add them to initiative")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .frame(minWidth: 300)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach($combatents) { $combatent in
                                        InitiativeCard(
                                            combatent: combatent,
                                            isSelected: selectedInitiativeCombatentID == combatent.id
                                        ) {
                                            selectOrAssignStatus(to: combatent)
                                        } onEdit: {
                                            editingCombatentID = combatent.id
                                        } onStatusDrop: { payloads in
                                            assignDraggedStatus(from: payloads, to: combatent.id)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .background(.bar)
                    .overlay {
                        if isInitiativeTargeted {
                            Rectangle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .allowsHitTesting(false)
                        }
                    }
                    .dropDestination(for: String.self) { ids, _ in
                        var added: [Combatent] = []
                        for id in ids {
                            if id.hasPrefix("player-") {
                                let existsInTracker = combatents.contains { $0.sourceSidebarID == id }
                                let existsInAdded = added.contains { $0.sourceSidebarID == id }
                                if existsInTracker || existsInAdded {
                                    continue
                                }
                            }
                            if let newCombatent = makeCombatent(from: id) {
                                added.append(newCombatent)
                            }
                        }
                        combatents.append(contentsOf: added)
                        combatents.sort { $0.initiative > $1.initiative }
                        return !added.isEmpty
                    } isTargeted: { targeted in
                        isInitiativeTargeted = targeted
                    }

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let selectedInitiativeCombatent {
                                InitiativeSelectionDetailView(
                                    combatent: selectedInitiativeCombatent,
                                    player: player(for: selectedInitiativeCombatent.sourceSidebarID),
                                    monster: monster(for: selectedInitiativeCombatent.sourceSidebarID),
                                    npc: npc(for: selectedInitiativeCombatent.sourceSidebarID)
                                )
                            } else if let selectedPlayer {
                                PlayerCharacterDetailView(player: selectedPlayer, encounterCombatent: nil)
                            } else if let selectedMonster {
                                MonsterDetailView(monster: selectedMonster, encounterCombatent: nil)
                            } else if let selectedNPC {
                                NPCDetailView(npc: selectedNPC, encounterCombatent: nil)
                            } else if let selectedItem = selectedSidebarItem {
                                Text(selectedItem.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text("Detail view content goes here.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button {
                            longRest()
                        } label: {
                            Label("Long Rest", systemImage: "bed.double")
                        }
                        .help("Long Rest")
                    }

                    ToolbarItem {
                        Button {
                            isStatusPalettePresented.toggle()
                        } label: {
                            Label(statusPaletteButtonTitle, systemImage: "cross.case")
                        }
                        .popover(isPresented: $isStatusPalettePresented) {
                            StatusPaletteView(statuses: assignableStatuses) { status in
                                pendingStatus = status
                                isStatusPalettePresented = false
                            }
                        }
                        .help(statusPaletteHelpText)
                    }

                    ToolbarItem {
                        Menu {
                            Button("Character") {}
                            Button("Private Asset") {}
                            Button("Public Asset") {}
                            Button("Statuses") {
                                isStatusPalettePresented = true
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: isShowingCombatentEditor) {
                    if let editingCombatent {
                        InitiativeEditorView(combatent: editingCombatent)
                    }
                }
            }
        }
    }

    private var statusPaletteButtonTitle: String {
        pendingStatus.map { "Assign \($0.name)" } ?? "Statuses"
    }

    private var statusPaletteHelpText: String {
        pendingStatus.map { "Click an initiative card to assign \($0.name)" } ?? "Statuses"
    }

    private var assignableStatuses: [StatusCondition] {
        uniqueStatuses(
            from: defaultStatusConditions
                + testPlayers.flatMap { $0.status ?? [] }
                + testMonsters.flatMap { $0.status ?? [] }
                + testNPCs.flatMap { $0.status ?? [] }
                + testCombatents.flatMap { $0.status ?? [] }
                + combatents.flatMap { $0.status ?? [] }
        )
    }

    private func longRest() {
        for index in combatents.indices {
            combatents[index].currentHP = combatents[index].maxHP
            combatents[index].status = nil
        }
        for index in testPlayers.indices {
            testPlayers[index].currentHP = testPlayers[index].maxHP
            testPlayers[index].status = nil
        }
    }

    private func selectOrAssignStatus(to combatent: Combatent) {
        selectedInitiativeCombatentID = combatent.id

        if let sourceSidebarID = combatent.sourceSidebarID {
            selectedItemID = sourceSidebarID
        }

        guard let pendingStatus else { return }

        assignStatus(pendingStatus, to: combatent.id)
        self.pendingStatus = nil
    }

    private func assignDraggedStatus(from payloads: [String], to combatentID: Combatent.ID) -> Bool {
        let statuses = payloads.compactMap(statusFromDragPayload)

        for status in statuses {
            assignStatus(status, to: combatentID)
        }

        return !statuses.isEmpty
    }

    private func assignStatus(_ status: StatusCondition, to combatentID: Combatent.ID) {
        guard let index = combatents.firstIndex(where: { $0.id == combatentID }) else { return }

        var statuses = combatents[index].status ?? []
        if !statuses.contains(where: { $0.name == status.name }) {
            statuses.append(status)
        }
        combatents[index].status = statuses
    }

    private func statusFromDragPayload(_ payload: String) -> StatusCondition? {
        guard payload.hasPrefix(statusDragPayloadPrefix) else { return nil }

        let statusName = String(payload.dropFirst(statusDragPayloadPrefix.count))
        return assignableStatuses.first { $0.name == statusName }
    }

    private func uniqueStatuses(from statuses: [StatusCondition]) -> [StatusCondition] {
        var seenNames: Set<String> = []

        return statuses.filter { status in
            if seenNames.contains(status.name) {
                return false
            }

            seenNames.insert(status.name)
            return true
        }
    }

    private var editingCombatent: Binding<Combatent>? {
        guard let editingCombatentID else { return nil }

        return Binding {
            combatents.first { $0.id == editingCombatentID } ?? Combatent(
                name: "",
                currentHP: 0,
                maxHP: 0,
                initiative: 0,
                isTurn: false,
                status: nil,
                spellSlotCount: 0,
                sourceSidebarID: nil
            )
        } set: { updatedCombatent in
            guard let index = combatents.firstIndex(where: { $0.id == editingCombatentID }) else { return }
            combatents[index] = updatedCombatent
        }
    }

    private var selectedInitiativeCombatent: Combatent? {
        guard let selectedInitiativeCombatentID else { return nil }
        return combatents.first { $0.id == selectedInitiativeCombatentID }
    }

    private var selectedSidebarItem: SidebarItem? {
        findSidebarItem(withID: selectedItemID, in: sidebarItems)
    }

    private var selectedPlayer: PlayerCharacter? {
        player(for: selectedItemID)
    }

    private var selectedMonster: Monster? {
        monster(for: selectedItemID)
    }

    private var selectedNPC: NPC? {
        npc(for: selectedItemID)
    }

    private func findSidebarItem(withID id: String?, in items: [SidebarItem]) -> SidebarItem? {
        guard let id else { return nil }

        for item in items {
            if item.id == id { return item }
            if let childMatch = findSidebarItem(withID: id, in: item.children ?? []) { return childMatch }
        }

        return nil
    }

    private func entity<T: CombatParticipant>(for sidebarID: String?, prefix: String, in collection: [T]) -> T? {
        guard let sidebarID, sidebarID.hasPrefix(prefix + "-") else { return nil }
        let rawID = String(sidebarID.dropFirst(prefix.count + 1))
        return collection.first { $0.id.uuidString == rawID }
    }

    private func player(for sidebarID: String?) -> PlayerCharacter? {
        entity(for: sidebarID, prefix: "player", in: testPlayers)
    }

    private func monster(for sidebarID: String?) -> Monster? {
        entity(for: sidebarID, prefix: "monster", in: testMonsters)
    }

    private func npc(for sidebarID: String?) -> NPC? {
        entity(for: sidebarID, prefix: "character", in: testNPCs)
    }

    private func makeCombatent<T: CombatParticipant>(from participant: T, sidebarID: String) -> Combatent {
        Combatent(
            name: participant.name,
            currentHP: participant.currentHP,
            maxHP: participant.maxHP,
            initiative: rolledInitiative(for: participant.abilityScores),
            isTurn: false,
            status: participant.status,
            spellSlotCount: participant.spellSlotCount,
            sourceSidebarID: sidebarID
        )
    }

    private func makeCombatent(from sidebarID: String) -> Combatent? {
        if let p = entity(for: sidebarID, prefix: "player", in: testPlayers) {
            return makeCombatent(from: p, sidebarID: sidebarID)
        }
        if let m = entity(for: sidebarID, prefix: "monster", in: testMonsters) {
            return makeCombatent(from: m, sidebarID: sidebarID)
        }
        if let n = entity(for: sidebarID, prefix: "character", in: testNPCs) {
            return makeCombatent(from: n, sidebarID: sidebarID)
        }
        return nil
    }

    private func rolledInitiative(for abilityScores: AbilityScores) -> Double {
        let roll = Int.random(in: 1...20)
        let initiativeBonus = Int(floor(Double(abilityScores.dexterity - 10) / 2))
        return Double(roll + initiativeBonus)
    }
}

// MARK: - Views

struct InitiativeSelectionDetailView: View {
    let combatent: Combatent
    let player: PlayerCharacter?
    let monster: Monster?
    let npc: NPC?

    var body: some View {
        if let player {
            PlayerCharacterDetailView(player: player, encounterCombatent: combatent)
        } else if let monster {
            MonsterDetailView(monster: monster, encounterCombatent: combatent)
        } else if let npc {
            NPCDetailView(npc: npc, encounterCombatent: combatent)
        } else {
            CombatentDetailView(combatent: combatent)
        }
    }
}

struct PlayerCharacterDetailView: View {
    let player: PlayerCharacter
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? player.status ?? []
    }

    private var currentHP: Int {
        encounterCombatent?.currentHP ?? player.currentHP
    }

    private var maxHP: Int {
        encounterCombatent?.maxHP ?? player.maxHP
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("\(player.race) \(player.playerClass) \(player.level)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("HP \(currentHP)/\(maxHP)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            CreatureSummaryGrid(
                armorClass: player.armorClass,
                armorSource: player.armorSource,
                hitDice: player.hitDice,
                initiative: encounterCombatent?.initiative ?? player.initiative,
                speed: player.speed,
                senses: player.senses,
                languages: []
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: player.spellSlots, encounterSlotCount: encounterCombatent?.spellSlotCount)
            AbilityScoresView(scores: player.abilityScores)
            SpecialAbilitiesView(abilities: player.specialAbilities)
            ActionsView(actions: player.actions)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct MonsterDetailView: View {
    let monster: Monster
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? monster.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: monster.name,
                subtitle: "\(monster.size.rawValue) \(monster.type.rawValue), \(monster.alignment.rawValue)",
                hpText: "HP \(encounterCombatent?.currentHP ?? monster.currentHP)/\(encounterCombatent?.maxHP ?? monster.maxHP)"
            )

            CreatureSummaryGrid(
                armorClass: monster.armorClass,
                armorSource: monster.armorSource,
                hitDice: monster.hitDice,
                initiative: encounterCombatent?.initiative ?? monster.initiative,
                speed: monster.speed,
                senses: monster.senses,
                languages: monster.languages
            )

            DetailSection(title: "Challenge") {
                HStack {
                    Text("CR \(monster.challengeRating, specifier: "%g")")
                    Spacer()
                    Text("\(monster.xp) XP")
                        .foregroundStyle(.secondary)
                }
            }

            StatusesView(statuses: activeStatuses)
            AbilityScoresView(scores: monster.abilityScores)
            SpecialAbilitiesView(abilities: monster.specialAbilities)
            ActionsView(actions: monster.actions)

            if let legendaryActions = monster.legendaryActions, !legendaryActions.isEmpty {
                LegendaryActionsView(actions: legendaryActions, count: monster.legendaryActionCount)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct NPCDetailView: View {
    let npc: NPC
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? npc.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: npc.name,
                subtitle: "\(npc.role) - \(npc.size.rawValue), \(npc.alignment.rawValue)",
                hpText: "HP \(encounterCombatent?.currentHP ?? npc.currentHP)/\(encounterCombatent?.maxHP ?? npc.maxHP)"
            )

            Text(npc.biography)
                .foregroundStyle(.secondary)

            CreatureSummaryGrid(
                armorClass: npc.armorClass,
                armorSource: npc.armorSource,
                hitDice: npc.hitDice,
                initiative: encounterCombatent?.initiative ?? npc.initiative,
                speed: npc.speed,
                senses: npc.senses,
                languages: npc.languages
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: npc.spellSlots, encounterSlotCount: encounterCombatent?.spellSlotCount)
            AbilityScoresView(scores: npc.abilityScores)
            SpecialAbilitiesView(abilities: npc.specialAbilities)
            ActionsView(actions: npc.actions)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct CombatentDetailView: View {
    let combatent: Combatent

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: combatent.name,
                subtitle: "Initiative \(Int(combatent.initiative))",
                hpText: "HP \(combatent.currentHP)/\(combatent.maxHP)"
            )

            if combatent.spellSlotCount > 0 {
                DetailSection(title: "Spell Slots") {
                    Text("\(combatent.spellSlotCount) remaining")
                        .foregroundStyle(.secondary)
                }
            }

            StatusesView(statuses: combatent.status ?? [])
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct DetailHeader: View {
    let title: String
    let subtitle: String
    let hpText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(hpText)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            content
        }
    }
}

struct CreatureSummaryGrid: View {
    let armorClass: Int
    let armorSource: String
    let hitDice: String
    let initiative: Double
    let speed: MovementSpeed
    let senses: Senses
    let languages: [String]

    private let columns = [
        GridItem(.adaptive(minimum: 160), alignment: .topLeading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            SummaryMetric(title: "Armor Class", value: "\(armorClass) \(armorSource)")
            SummaryMetric(title: "Hit Dice", value: hitDice)
            SummaryMetric(title: "Initiative", value: "\(Int(initiative))")
            SummaryMetric(title: "Speed", value: speedText)
            SummaryMetric(title: "Senses", value: sensesText)

            if !languages.isEmpty {
                SummaryMetric(title: "Languages", value: languages.joined(separator: ", "))
            }
        }
    }

    private var speedText: String {
        var parts = ["\(speed.walk) ft."]

        if let swim = speed.swim {
            parts.append("swim \(swim) ft.")
        }
        if let fly = speed.fly {
            parts.append("fly \(fly) ft.\(speed.hover ? " hover" : "")")
        }
        if let climb = speed.climb {
            parts.append("climb \(climb) ft.")
        }
        if let burrow = speed.burrow {
            parts.append("burrow \(burrow) ft.")
        }

        return parts.joined(separator: ", ")
    }

    private var sensesText: String {
        var parts: [String] = []

        if let darkvision = senses.darkvision {
            parts.append("darkvision \(darkvision) ft.")
        }
        if let blindsight = senses.blindsight {
            parts.append("blindsight \(blindsight) ft.")
        }
        if let tremorsense = senses.tremorsense {
            parts.append("tremorsense \(tremorsense) ft.")
        }
        if let truesight = senses.truesight {
            parts.append("truesight \(truesight) ft.")
        }

        parts.append("passive \(senses.passivePerception)")
        return parts.joined(separator: ", ")
    }
}

struct SummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct StatusesView: View {
    let statuses: [StatusCondition]

    var body: some View {
        DetailSection(title: "Statuses") {
            if statuses.isEmpty {
                Text("No active statuses")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(statuses, id: \.name) { status in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(status.name)
                            .font(.headline)

                        Text(status.effect)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(status.desc)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}

struct SpellSlotsView: View {
    let slots: [SpellSlot]
    let encounterSlotCount: Int?

    var body: some View {
        DetailSection(title: "Spell Slots") {
            if let encounterSlotCount {
                HStack {
                    Text("Remaining")
                    Spacer()
                    Text("\(encounterSlotCount)")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
            } else if slots.isEmpty {
                Text("No spell slots")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(slots, id: \.level) { slot in
                    HStack {
                        Text("Level \(slot.level)")
                        Spacer()
                        Text("\(slot.count)")
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct AbilityScoresView: View {
    let scores: AbilityScores

    var body: some View {
        DetailSection(title: "Ability Scores") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 8) {
                AbilityScoreCell(label: "STR", value: scores.strength, modifier: scores.strMod)
                AbilityScoreCell(label: "DEX", value: scores.dexterity, modifier: scores.dexMod)
                AbilityScoreCell(label: "CON", value: scores.constitution, modifier: scores.conMod)
                AbilityScoreCell(label: "INT", value: scores.intelligence, modifier: scores.intMod)
                AbilityScoreCell(label: "WIS", value: scores.wisdom, modifier: scores.wisMod)
                AbilityScoreCell(label: "CHA", value: scores.charisma, modifier: scores.chaMod)
            }
        }
    }
}

struct AbilityScoreCell: View {
    let label: String
    let value: Int
    let modifier: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.headline)

            Text(modifierText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var modifierText: String {
        modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}

struct SpecialAbilitiesView: View {
    let abilities: [SpecialAbility]

    var body: some View {
        DetailSection(title: "Special Abilities") {
            if abilities.isEmpty {
                Text("No special abilities")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(abilities, id: \.name) { ability in
                    DescriptionRow(title: ability.name, detail: ability.description)
                }
            }
        }
    }
}

struct ActionsView: View {
    let actions: [Attack]

    var body: some View {
        DetailSection(title: "Actions") {
            if actions.isEmpty {
                Text("No actions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(actions, id: \.name) { action in
                    DescriptionRow(
                        title: action.name,
                        detail: "+\(action.hitBonus) to hit, \(action.reach), \(action.damageRoll) \(action.damageType.rawValue)"
                    )
                }
            }
        }
    }
}

struct LegendaryActionsView: View {
    let actions: [LegendaryAction]
    let count: Int?

    var body: some View {
        DetailSection(title: "Legendary Actions") {
            if let count {
                Text("\(count) per round")
                    .foregroundStyle(.secondary)
            }

            ForEach(actions, id: \.name) { action in
                DescriptionRow(title: "\(action.name) (\(action.cost))", detail: action.description)
            }
        }
    }
}

struct DescriptionRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)

            Text(detail)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

struct StatusPaletteView: View {
    let statuses: [StatusCondition]
    var onSelect: (StatusCondition) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(statuses, id: \.name) { status in
                    Button {
                        onSelect(status)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(status.name)
                                .font(.headline)

                            Text(status.effect)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .draggable(statusDragPayload(for: status))
                    .help("Click to queue, or drag onto an initiative card")
                }
            }
            .padding()
        }
        .frame(width: 260, height: 360)
    }
}

struct InitiativeCard: View {
    var combatent: Combatent
    var isSelected: Bool
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onStatusDrop: ([String]) -> Bool
    @State private var isStatusTargeted = false

    private var activeStatuses: [StatusCondition] {
        combatent.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(combatent.name)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(Int(combatent.initiative))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text("HP: \(combatent.currentHP)/\(combatent.maxHP)")
                .font(.subheadline)

            if combatent.spellSlotCount > 0 {
                Text("Spell slots: \(combatent.spellSlotCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !activeStatuses.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Statuses")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(activeStatuses, id: \.name) { status in
                        Text(status.name)
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .frame(width: 220, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: isSelected || combatent.isTurn ? 2 : 1)
        }
        .overlay {
            if isStatusTargeted {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture(perform: onSelect)
        .onLongPressGesture(perform: onEdit)
        .dropDestination(for: String.self) { payloads, _ in
            onStatusDrop(payloads)
        } isTargeted: { targeted in
            isStatusTargeted = targeted
        }
        .contextMenu {
            Button("Edit") {
                onEdit()
            }
        }
        .help("Long press or secondary-click to edit")
    }

    private var cardStrokeColor: Color {
        if isSelected {
            return .accentColor
        }
        return combatent.isTurn ? .orange : Color.secondary.opacity(0.2)
    }
}

struct InitiativeEditorView: View {
    @Binding var combatent: Combatent
    @Environment(\.dismiss) private var dismiss

    private var statuses: Binding<[StatusCondition]> {
        Binding {
            combatent.status ?? []
        } set: { updatedStatuses in
            combatent.status = updatedStatuses.isEmpty ? nil : updatedStatuses
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Combatant") {
                    TextField("Name", text: $combatent.name)

                    Toggle("Current Turn", isOn: $combatent.isTurn)

                    HStack {
                        Text("Initiative")
                        Spacer()
                        TextField("Initiative", value: $combatent.initiative, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 96)
                    }
                }

                Section("Hit Points") {
                    Stepper(value: $combatent.currentHP, in: 0...max(999, combatent.maxHP)) {
                        StatValueRow(title: "Current HP", value: combatent.currentHP)
                    }

                    Stepper(value: $combatent.maxHP, in: 1...999) {
                        StatValueRow(title: "Max HP", value: combatent.maxHP)
                    }
                }

                Section("Spell Slots") {
                    Stepper(value: $combatent.spellSlotCount, in: 0...99) {
                        StatValueRow(title: "Remaining Slots", value: combatent.spellSlotCount)
                    }
                }

                Section("Statuses") {
                    let statusBindings = statuses

                    if statusBindings.wrappedValue.isEmpty {
                        Text("No active statuses")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(statusBindings.wrappedValue.indices, id: \.self) { index in
                            StatusEditorRow(statuses: statusBindings, index: index)
                        }
                    }

                    Button {
                        statusBindings.wrappedValue.append(
                            StatusCondition(name: "New Status", effect: "", desc: "")
                        )
                    } label: {
                        Label("Add Status", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Initiative")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 420, minHeight: 520)
        .onChange(of: combatent.maxHP) { _, newMaxHP in
            combatent.currentHP = min(combatent.currentHP, newMaxHP)
        }
    }
}

struct StatValueRow: View {
    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

struct StatusEditorRow: View {
    @Binding var statuses: [StatusCondition]
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                TextField("Name", text: binding(for: \.name))
                    .fontWeight(.semibold)

                Spacer()

                Button(role: .destructive) {
                    statuses.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Remove status")
            }

            TextField("Effect", text: binding(for: \.effect))

            TextField("Description", text: binding(for: \.desc), axis: .vertical)
                .lineLimit(2...4)
        }
        .padding(.vertical, 6)
    }

    private func binding(for keyPath: WritableKeyPath<StatusCondition, String>) -> Binding<String> {
        Binding {
            guard statuses.indices.contains(index) else { return "" }
            return statuses[index][keyPath: keyPath]
        } set: { updatedValue in
            guard statuses.indices.contains(index) else { return }
            statuses[index][keyPath: keyPath] = updatedValue
        }
    }
}

private let statusDragPayloadPrefix = "status:"

private func statusDragPayload(for status: StatusCondition) -> String {
    "\(statusDragPayloadPrefix)\(status.name)"
}

private let defaultStatusConditions: [StatusCondition] = [
    StatusCondition(name: "Blinded", effect: "Cannot see", desc: "Automatically fails sight-based checks. Attacks against the creature have advantage, and its attacks have disadvantage."),
    StatusCondition(name: "Charmed", effect: "Cannot harm charmer", desc: "Cannot attack the charmer or target them with harmful abilities. The charmer has advantage on social checks against it."),
    StatusCondition(name: "Deafened", effect: "Cannot hear", desc: "Automatically fails hearing-based checks."),
    StatusCondition(name: "Exhaustion", effect: "Cumulative penalties", desc: "Suffers cumulative penalties based on exhaustion level."),
    StatusCondition(name: "Frightened", effect: "Disadvantage", desc: "Has disadvantage on ability checks and attack rolls while the source of fear is in sight, and cannot willingly move closer."),
    StatusCondition(name: "Grappled", effect: "Speed 0", desc: "Speed becomes 0 and cannot benefit from bonuses to speed."),
    StatusCondition(name: "Incapacitated", effect: "No actions", desc: "Cannot take actions or reactions."),
    StatusCondition(name: "Invisible", effect: "Unseen", desc: "Cannot be seen without special senses. Attacks against it have disadvantage, and its attacks have advantage."),
    StatusCondition(name: "Paralyzed", effect: "Incapacitated", desc: "Cannot move or speak. Fails Strength and Dexterity saves. Attacks against it have advantage; nearby hits are critical hits."),
    StatusCondition(name: "Petrified", effect: "Transformed", desc: "Transformed into solid material, incapacitated, unaware, resistant to damage, and fails Strength and Dexterity saves."),
    StatusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Has disadvantage on attack rolls and ability checks."),
    StatusCondition(name: "Prone", effect: "On the ground", desc: "Can crawl or stand. Attacks against it have advantage within 5 feet and disadvantage from farther away."),
    StatusCondition(name: "Restrained", effect: "Speed 0", desc: "Speed becomes 0. Attacks against it have advantage, its attacks have disadvantage, and it has disadvantage on Dexterity saves."),
    StatusCondition(name: "Stunned", effect: "Incapacitated", desc: "Cannot move, can speak only falteringly, fails Strength and Dexterity saves, and attacks against it have advantage."),
    StatusCondition(name: "Unconscious", effect: "Incapacitated", desc: "Drops prone, cannot move or speak, is unaware, fails Strength and Dexterity saves, and nearby hits are critical hits.")
]

#Preview {
    ContentView()
}
