import SwiftUI
import Observation

enum InventoryEntityType { case player, monster, npc }

struct SearchResult: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let sidebarID: String
}

@Observable
@MainActor
final class CampaignViewModel {
    var selectedItemID: String? = "players"
    var wikiEntries: [WikiEntry] = wikiDemoData
    var lootItems: [LootItem] = lootDemoData
    var spellEntries: [SpellEntry] = spellDemoData
    var playerInventories: [UUID: [InventoryItem]] = [:]
    var monsterInventories: [UUID: [InventoryItem]] = [:]
    var npcInventories: [UUID: [InventoryItem]] = [:]
    var combatents: [Combatent] = []
    var selectedInitiativeCombatentID: Combatent.ID?
    var isInitiativeTargeted = false
    var editingCombatentID: Combatent.ID?
    var isStatusPalettePresented = false
    var isLongRestConfirmationPresented = false
    var isCharacterCreationPresented = false
    var isWikiEntryCreationPresented = false
    var isSearchPresented = false
    var searchQuery = ""
    var isRollHistoryPresented = false
    var rollHistory: [RollEntry] = []
    var hasNewRollHistory = false
    var pendingStatus: StatusCondition?

    private let dataService: CampaignDataService

    init(dataService: CampaignDataService) {
        self.dataService = dataService
        // Wizard (index 0): ring of protection equipped, bag of holding in pack
        if testPlayers.count > 0 {
            playerInventories[testPlayers[0].id] = [
                InventoryItem(lootItemID: "ring-of-protection", isEquipped: true),
                InventoryItem(lootItemID: "bag-of-holding")
            ]
        }
        // Barbarian (index 1): gauntlets equipped, potion in pack
        if testPlayers.count > 1 {
            playerInventories[testPlayers[1].id] = [
                InventoryItem(lootItemID: "gauntlets-of-ogre-power", isEquipped: true),
                InventoryItem(lootItemID: "potion-of-healing")
            ]
        }
        // Warlock (index 2): cloak and staff in pack
        if testPlayers.count > 2 {
            playerInventories[testPlayers[2].id] = [
                InventoryItem(lootItemID: "cloak-of-elvenkind"),
                InventoryItem(lootItemID: "staff-of-the-python")
            ]
        }
        // Paladin (index 3): dwarven thrower equipped, amulet of health equipped
        if testPlayers.count > 3 {
            playerInventories[testPlayers[3].id] = [
                InventoryItem(lootItemID: "dwarven-thrower", isEquipped: true),
                InventoryItem(lootItemID: "amulet-of-health", isEquipped: true)
            ]
        }
        // Guard Captain NPC (index 0): sword of vengeance equipped
        if testNPCs.count > 0 {
            npcInventories[testNPCs[0].id] = [
                InventoryItem(lootItemID: "sword-of-vengeance", isEquipped: true),
                InventoryItem(lootItemID: "ring-of-protection")
            ]
        }
        // Archmage NPC (index 2): staff equipped, deck of illusions in pack
        if testNPCs.count > 2 {
            npcInventories[testNPCs[2].id] = [
                InventoryItem(lootItemID: "staff-of-the-python", isEquipped: true),
                InventoryItem(lootItemID: "deck-of-illusions")
            ]
        }
    }

    // MARK: - Computed

    var statusPaletteButtonTitle: String {
        pendingStatus.map { "Assign \($0.name)" } ?? "Statuses"
    }

    var statusPaletteHelpText: String {
        pendingStatus.map { "Click an initiative card to assign \($0.name)" } ?? "Statuses"
    }

    var assignableStatuses: [StatusCondition] {
        let all = defaultStatusConditions
            + testPlayers.flatMap { $0.status ?? [] }
            + testMonsters.flatMap { $0.status ?? [] }
            + testNPCs.flatMap { $0.status ?? [] }
            + testCombatents.flatMap { $0.status ?? [] }
            + combatents.flatMap { $0.status ?? [] }
        return uniqueStatuses(from: all)
    }

    var selectedInitiativeCombatent: Combatent? {
        guard let selectedInitiativeCombatentID else { return nil }
        return combatents.first { $0.id == selectedInitiativeCombatentID }
    }

    var sidebarItems: [SidebarItem] {
        [
            SidebarItem(
                id: "players",
                title: "Players",
                systemImage: "person.2",
                children: testPlayers.map { player in
                    SidebarItem(
                        id: "player-\(player.id.uuidString)",
                        title: player.name,
                        systemImage: "person",
                        children: nil
                    )
                }
            ),
            SidebarItem(
                id: "npcs",
                title: "NPCs",
                systemImage: "person.3",
                children: [
                    SidebarItem(
                        id: "npc-monsters",
                        title: "Monsters",
                        systemImage: "ant",
                        children: testMonsters.map { monster in
                            SidebarItem(
                                id: "monster-\(monster.id.uuidString)",
                                title: monster.name,
                                systemImage: "ant.fill",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(
                        id: "npc-characters",
                        title: "Characters",
                        systemImage: "person.2",
                        children: testNPCs.map { npc in
                            SidebarItem(
                                id: "character-\(npc.id.uuidString)",
                                title: npc.name,
                                systemImage: "person.fill",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(id: "npc-other", title: "Other", systemImage: "square.grid.2x2", children: nil)
                ]
            ),
            SidebarItem(id: "public-assets", title: "Public Assets", systemImage: "globe", children: nil),
            SidebarItem(id: "private-assets", title: "Private Assets", systemImage: "lock", children: nil),
            SidebarItem(
                id: "wiki",
                title: "Wiki",
                systemImage: "book.pages",
                children: [
                    SidebarItem(
                        id: "wiki-entries",
                        title: "Entries",
                        systemImage: "doc.text",
                        children: wikiEntries.map { entry in
                            SidebarItem(
                                id: "wiki-\(entry.id)",
                                title: entry.title,
                                systemImage: "doc.text",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(
                        id: "wiki-loot",
                        title: "Loot",
                        systemImage: "backpack",
                        children: lootItems.map { item in
                            SidebarItem(
                                id: "loot-\(item.id)",
                                title: item.name,
                                systemImage: "diamond",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(
                        id: "wiki-spells",
                        title: "Spells",
                        systemImage: "sparkles",
                        children: spellSidebarGroups()
                    )
                ]
            )
        ]
    }

    var selectedSidebarItem: SidebarItem? {
        dataService.sidebarItem(withID: selectedItemID, in: sidebarItems)
    }

    var selectedPlayer: PlayerCharacter? {
        dataService.player(for: selectedItemID)
    }

    var selectedMonster: Monster? {
        dataService.monster(for: selectedItemID)
    }

    var selectedNPC: NPC? {
        dataService.npc(for: selectedItemID)
    }

    var selectedWikiEntry: WikiEntry? {
        guard let id = selectedItemID, id.hasPrefix("wiki-") else { return nil }
        return wikiEntries.first { $0.id == String(id.dropFirst(5)) }
    }

    var selectedLootItem: LootItem? {
        guard let id = selectedItemID, id.hasPrefix("loot-") else { return nil }
        return lootItems.first { $0.id == String(id.dropFirst(5)) }
    }

    var selectedSpellEntry: SpellEntry? {
        guard let id = selectedItemID, id.hasPrefix("spell-") else { return nil }
        return spellEntries.first { $0.id == String(id.dropFirst(6)) }
    }

    var selectedPlayerInventory: [InventoryItem] {
        guard let id = selectedPlayer?.id else { return [] }
        return playerInventories[id] ?? []
    }

    var selectedMonsterInventory: [InventoryItem] {
        guard let id = selectedMonster?.id else { return [] }
        return monsterInventories[id] ?? []
    }

    var selectedNPCInventory: [InventoryItem] {
        guard let id = selectedNPC?.id else { return [] }
        return npcInventories[id] ?? []
    }

    func equippedModifiers(for entityID: UUID, entityType: InventoryEntityType) -> EquippedModifiers {
        let inv: [InventoryItem]
        switch entityType {
        case .player:  inv = playerInventories[entityID] ?? []
        case .monster: inv = monsterInventories[entityID] ?? []
        case .npc:     inv = npcInventories[entityID] ?? []
        }
        return lootItems.equippedModifiers(for: inv)
    }

    func toggleEquip(inventoryItemID: UUID, forEntity entityID: UUID, entityType: InventoryEntityType) {
        switch entityType {
        case .player:
            guard let idx = playerInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            playerInventories[entityID]![idx].isEquipped.toggle()
        case .monster:
            guard let idx = monsterInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            monsterInventories[entityID]![idx].isEquipped.toggle()
        case .npc:
            guard let idx = npcInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            npcInventories[entityID]![idx].isEquipped.toggle()
        }
    }

    var searchResults: [SearchResult] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard query.count >= 1 else { return [] }

        var results: [SearchResult] = []

        for monster in testMonsters {
            if monster.name.lowercased().contains(query) || monster.type.rawValue.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "monster-\(monster.id.uuidString)",
                    title: monster.name,
                    subtitle: "\(monster.type.rawValue) • CR \(monster.challengeRating)",
                    systemImage: "ant.fill",
                    sidebarID: "monster-\(monster.id.uuidString)"
                ))
            }
        }

        for npc in testNPCs {
            if npc.name.lowercased().contains(query) || npc.role.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "character-\(npc.id.uuidString)",
                    title: npc.name,
                    subtitle: npc.role,
                    systemImage: "person.fill",
                    sidebarID: "character-\(npc.id.uuidString)"
                ))
            }
        }

        for player in testPlayers {
            if player.name.lowercased().contains(query) || player.race.lowercased().contains(query) || player.playerClass.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "player-\(player.id.uuidString)",
                    title: player.name,
                    subtitle: "\(player.race) \(player.playerClass) • Level \(player.level)",
                    systemImage: "person",
                    sidebarID: "player-\(player.id.uuidString)"
                ))
            }
        }

        for entry in wikiEntries {
            let matchesTitle = entry.title.lowercased().contains(query)
            let matchesDesc = entry.description.lowercased().contains(query)
            let matchesAlias = entry.aliases.contains { $0.lowercased().contains(query) }
            if matchesTitle || matchesDesc || matchesAlias {
                results.append(SearchResult(
                    id: "wiki-\(entry.id)",
                    title: entry.title,
                    subtitle: "Wiki",
                    systemImage: "doc.text",
                    sidebarID: "wiki-\(entry.id)"
                ))
            }
        }

        for item in lootItems {
            let matchesName = item.name.lowercased().contains(query)
            let matchesType = item.type.lowercased().contains(query)
            let matchesRarity = item.rarity.lowercased().contains(query)
            let matchesDesc = item.description.lowercased().contains(query)
            if matchesName || matchesType || matchesRarity || matchesDesc {
                results.append(SearchResult(
                    id: "loot-\(item.id)",
                    title: item.name,
                    subtitle: "\(item.type) • \(item.rarity)",
                    systemImage: "diamond",
                    sidebarID: "loot-\(item.id)"
                ))
            }
        }

        return results
    }

    var editingCombatent: Binding<Combatent>? {
        guard let editingCombatentID else { return nil }
        return Binding {
            self.combatents.first { $0.id == editingCombatentID } ?? Combatent(
                name: "",
                currentHP: 0,
                maxHP: 0,
                initiative: 0,
                isTurn: false,
                status: nil,
                creatureType: nil,
                spellSlots: [],
                speed: MovementSpeed(walk: 0)
            )
        } set: { updatedCombatent in
            guard let index = self.combatents.firstIndex(where: { $0.id == editingCombatentID }) else { return }
            self.combatents[index] = updatedCombatent
        }
    }

    // MARK: - Actions

    func selectSidebarItem(_ id: String?) {
        selectedItemID = id
        selectedInitiativeCombatentID = nil
    }

    func addCombatents(from sidebarIDs: [String]) -> Bool {
        var added: [Combatent] = []
        for id in sidebarIDs {
            if id.hasPrefix("player-") {
                let existsInTracker = combatents.contains { $0.sourceSidebarID == id }
                let existsInAdded = added.contains { $0.sourceSidebarID == id }
                if existsInTracker || existsInAdded { continue }
            }
            let initiative: Double
            if let participant = dataService.combatParticipant(for: id) {
                let details = dataService.initiativeRoll(for: participant.abilityScores)
                logRoll(
                    type: "Initiative",
                    name: participant.name,
                    roll: details.roll,
                    modifier: details.modifier,
                    total: details.total
                )
                initiative = details.total
            } else {
                initiative = 0
            }
            if let newCombatent = dataService.makeCombatent(from: id, initiative: initiative) {
                added.append(newCombatent)
            }
        }
        combatents.append(contentsOf: added)
        combatents.sort { $0.initiative > $1.initiative }
        return !added.isEmpty
    }

    func logRoll(type: String, name: String, roll: Int, modifier: Int, total: Double) {
        let entry = RollEntry(
            type: type,
            name: name,
            roll: roll,
            modifier: modifier,
            total: total,
            timestamp: Date()
        )
        rollHistory.insert(entry, at: 0)
        hasNewRollHistory = true
    }

    func clearRollHistory() {
        rollHistory.removeAll()
        hasNewRollHistory = false
    }

    func markRollHistorySeen() {
        hasNewRollHistory = false
    }

    func rollAbilityCheck(name: String, modifier: Int) {
        let roll = Int.random(in: 1...20)
        logRoll(type: "Ability", name: name, roll: roll, modifier: modifier, total: Double(roll + modifier))
    }

    func rollSkillCheck(name: String, bonus: Int) {
        let roll = Int.random(in: 1...20)
        logRoll(type: "Skill", name: name, roll: roll, modifier: bonus, total: Double(roll + bonus))
    }

    func selectOrAssignStatus(to combatent: Combatent) {
        selectedInitiativeCombatentID = combatent.id
        if let sourceSidebarID = combatent.sourceSidebarID {
            selectedItemID = sourceSidebarID
        }
        guard let pendingStatus else { return }
        assignStatus(pendingStatus, to: combatent.id)
        self.pendingStatus = nil
    }

    func assignDraggedStatus(from payloads: [String], to combatentID: Combatent.ID) -> Bool {
        let statuses = payloads.compactMap(statusFromDragPayload)
        for status in statuses {
            assignStatus(status, to: combatentID)
        }
        return !statuses.isEmpty
    }

    func longRest() {
        for index in combatents.indices {
            combatents[index].currentHP = combatents[index].maxHP
            combatents[index].temporaryHP = 0
            combatents[index].status = nil
            for slotIndex in combatents[index].spellSlots.indices {
                combatents[index].spellSlots[slotIndex].available = combatents[index].spellSlots[slotIndex].max
            }
        }
        for index in testPlayers.indices {
            testPlayers[index].currentHP = testPlayers[index].maxHP
            testPlayers[index].status = nil
            for slotIndex in testPlayers[index].spellSlots.indices {
                testPlayers[index].spellSlots[slotIndex].available = testPlayers[index].spellSlots[slotIndex].max
            }
            for actionIndex in testPlayers[index].actions.indices {
                if let maxUses = testPlayers[index].actions[actionIndex].maxUses {
                    testPlayers[index].actions[actionIndex].remainingUses = maxUses
                }
            }
        }
    }

    func beginEditing(combatentID: Combatent.ID) {
        editingCombatentID = combatentID
    }

    func dismissEditor() {
        editingCombatentID = nil
    }

    func removeCombatent(id: Combatent.ID) {
        combatents.removeAll { $0.id == id }
        if selectedInitiativeCombatentID == id {
            selectedInitiativeCombatentID = nil
        }
        if editingCombatentID == id {
            editingCombatentID = nil
        }
    }

    func addLairAction() {
        let lairAction = Combatent(
            name: "Lair Action",
            currentHP: 0,
            maxHP: 0,
            initiative: 20,
            isTurn: false,
            status: nil,
            creatureType: "Lair Action",
            spellSlots: [],
            speed: MovementSpeed(walk: 0),
            isLairAction: true
        )
        combatents.append(lairAction)
        combatents.sort { $0.initiative > $1.initiative }
    }

    func advanceTurn() {
        guard !combatents.isEmpty else { return }
        let currentIndex = combatents.firstIndex(where: { $0.isTurn }) ?? -1
        let nextIndex = (currentIndex + 1) % combatents.count
        if currentIndex >= 0 {
            combatents[currentIndex].isTurn = false
        }
        combatents[nextIndex].isTurn = true
    }

    func rewindTurn() {
        guard !combatents.isEmpty else { return }
        let currentIndex = combatents.firstIndex(where: { $0.isTurn }) ?? combatents.count
        let prevIndex = (currentIndex - 1 + combatents.count) % combatents.count
        if currentIndex < combatents.count {
            combatents[currentIndex].isTurn = false
        }
        combatents[prevIndex].isTurn = true
    }

    func makeCurrentTurn(for combatentID: Combatent.ID) {
        for index in combatents.indices {
            combatents[index].isTurn = combatents[index].id == combatentID
        }
    }

    func queueStatus(_ status: StatusCondition) {
        pendingStatus = status
        isStatusPalettePresented = false
    }

    func createPlayerCharacter(_ player: PlayerCharacter) {
        testPlayers.append(player)
        selectedItemID = "player-\(player.id.uuidString)"
    }

    func createWikiEntry(_ entry: WikiEntry) {
        var id = entry.id
        var suffix = 2
        while wikiEntries.contains(where: { $0.id == id }) {
            id = "\(entry.id)-\(suffix)"
            suffix += 1
        }
        let stored = id == entry.id ? entry : WikiEntry(id: id, title: entry.title, description: entry.description, aliases: entry.aliases)
        wikiEntries.append(stored)
        selectedItemID = "wiki-\(stored.id)"
    }

    // MARK: - Action Use

    func useAction(_ action: Attack, forEntity entityID: UUID, entityType: InventoryEntityType, name: String) {
        var mutableAction = action
        if let remaining = mutableAction.remainingUses, remaining > 0 {
            mutableAction.remainingUses = remaining - 1
        }

        // Roll to-hit
        let toHitRoll = Int.random(in: 1...20)
        let toHitTotal = toHitRoll + action.hitBonus
        logRoll(type: "Action", name: "\(name) — \(action.name) (Attack)", roll: toHitRoll, modifier: action.hitBonus, total: Double(toHitTotal))

        // Roll damage
        let damageResult = rollDice(action.damageRoll)
        if damageResult.total > 0 {
            logRoll(type: "Action", name: "\(name) — \(action.name) (Damage)", roll: damageResult.rollSum, modifier: damageResult.modifier, total: Double(damageResult.total))
        }

        // Update entity actions
        switch entityType {
        case .player:
            guard let playerIndex = testPlayers.firstIndex(where: { $0.id == entityID }) else { return }
            guard let actionIndex = testPlayers[playerIndex].actions.firstIndex(where: { $0.id == action.id }) else { return }
            testPlayers[playerIndex].actions[actionIndex] = mutableAction
        case .monster, .npc:
            break
        }
    }

    // MARK: - Spell Casting

    func castSpell(_ spellEntry: SpellEntry, atLevel slotLevel: Int, forEntity entityID: UUID, entityType: InventoryEntityType, name: String) {
        // Expend slot
        if spellEntry.level > 0 {
            expendSpellSlot(level: slotLevel, for: entityID, entityType: entityType)
        }

        // Roll damage / healing if applicable
        if let damageRoll = spellEntry.damageRoll {
            let result = rollDice(damageRoll)
            let typeLabel = spellEntry.damageType.map { " \($0.rawValue)" } ?? ""
            logRoll(
                type: "Spell",
                name: "\(name) — \(spellEntry.name) (\(damageRoll)\(typeLabel))",
                roll: result.rollSum,
                modifier: result.modifier,
                total: Double(result.total)
            )
        } else {
            logRoll(
                type: "Spell",
                name: "\(name) — \(spellEntry.name)",
                roll: 0,
                modifier: 0,
                total: 0
            )
        }
    }

    private func expendSpellSlot(level: Int, for entityID: UUID, entityType: InventoryEntityType) {
        // Update entity spell slots
        switch entityType {
        case .player:
            guard let playerIndex = testPlayers.firstIndex(where: { $0.id == entityID }) else { return }
            guard let slotIndex = testPlayers[playerIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            testPlayers[playerIndex].spellSlots[slotIndex].available -= 1
        case .npc:
            guard let npcIndex = testNPCs.firstIndex(where: { $0.id == entityID }) else { return }
            guard let slotIndex = testNPCs[npcIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            testNPCs[npcIndex].spellSlots[slotIndex].available -= 1
        case .monster:
            return // Monsters don't have stored spell slots
        }

        // Update combatent spell slots if present
        let sidebarID: String
        switch entityType {
        case .player:  sidebarID = "player-\(entityID.uuidString)"
        case .monster: sidebarID = "monster-\(entityID.uuidString)"
        case .npc:     sidebarID = "character-\(entityID.uuidString)"
        }
        if let combatentIndex = combatents.firstIndex(where: { $0.sourceSidebarID == sidebarID }) {
            guard let slotIndex = combatents[combatentIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            combatents[combatentIndex].spellSlots[slotIndex].available -= 1
        }
    }

    // MARK: - Private

    private func spellSidebarGroups() -> [SidebarItem] {
        let grouped = Dictionary(grouping: spellEntries, by: \.level)
        return (0...9).compactMap { level -> SidebarItem? in
            guard let spells = grouped[level], !spells.isEmpty else { return nil }
            let groupTitle = level == 0 ? "Cantrips" : "Level \(level.romanNumeral)"
            return SidebarItem(
                id: "wiki-spells-\(level)",
                title: groupTitle,
                systemImage: level == 0 ? "sparkle" : "sparkles",
                children: spells.map { spell in
                    SidebarItem(id: "spell-\(spell.id)", title: spell.name, systemImage: "sparkle", children: nil)
                }
            )
        }
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
            if seenNames.contains(status.name) { return false }
            seenNames.insert(status.name)
            return true
        }
    }
}

private let statusDragPayloadPrefix = "status:"

func statusDragPayload(for status: StatusCondition) -> String {
    "\(statusDragPayloadPrefix)\(status.name)"
}

struct DiceRollResult {
    let rollSum: Int
    let modifier: Int
    let total: Int
}

func rollDice(_ expression: String) -> DiceRollResult {
    let trimmed = expression.trimmingCharacters(in: .whitespaces)
    // Parse formats: XdY+Z, XdY-Z, XdY, dY
    let pattern = try! NSRegularExpression(pattern: "^(\\d+)?d(\\d+)(?:\\s*([+-])\\s*(\\d+))?$", options: .caseInsensitive)
    let range = NSRange(trimmed.startIndex..., in: trimmed)
    guard let match = pattern.firstMatch(in: trimmed, options: [], range: range) else {
        return DiceRollResult(rollSum: 0, modifier: 0, total: 0)
    }

    let countStr = match.range(at: 1).location != NSNotFound ? String(trimmed[Range(match.range(at: 1), in: trimmed)!]) : nil
    let dieStr = String(trimmed[Range(match.range(at: 2), in: trimmed)!])
    let opStr = match.range(at: 3).location != NSNotFound ? String(trimmed[Range(match.range(at: 3), in: trimmed)!]) : nil
    let modStr = match.range(at: 4).location != NSNotFound ? String(trimmed[Range(match.range(at: 4), in: trimmed)!]) : nil

    let count = countStr.flatMap { Int($0) } ?? 1
    let die = Int(dieStr) ?? 0
    let modifier = modStr.flatMap { Int($0) } ?? 0
    let signedModifier = opStr == "-" ? -modifier : modifier

    var rollSum = 0
    for _ in 0..<count {
        rollSum += Int.random(in: 1...max(1, die))
    }

    return DiceRollResult(rollSum: rollSum, modifier: signedModifier, total: rollSum + signedModifier)
}
