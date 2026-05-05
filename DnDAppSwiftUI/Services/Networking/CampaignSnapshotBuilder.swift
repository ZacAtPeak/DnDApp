import Foundation

// MARK: - Snapshot

nonisolated struct CampaignReplicatedState: Codable, Equatable, Sendable {
    let dataVersion: Int

    let assignments: [PlayerAssignment]
    let combatents: [NetworkCombatent]
    let rollHistory: [NetworkRollEntry]
    let encounters: [NetworkEncounter]
    let playerInventories: [String: [NetworkInventoryItem]]
    let monsterInventories: [String: [NetworkInventoryItem]]
    let npcInventories: [String: [NetworkInventoryItem]]
    let wikiEntries: [NetworkWikiEntry]
    let lootItems: [NetworkLootItem]
    let spellEntries: [NetworkSpellEntry]
    let assets: [NetworkAsset]
    let players: [NetworkPlayerState]
    let monsters: [NetworkMonsterState]
    let npcs: [NetworkNPCState]
}

nonisolated struct CampaignNetworkSnapshot: Codable, Equatable, Sendable {
    static let currentSchemaVersion = 2

    let schemaVersion: Int
    let snapshotID: UUID
    let snapshotDate: Date
    let revision: Int
    let state: CampaignReplicatedState
}

// MARK: - Builder

@MainActor
enum CampaignSnapshotBuilder {

    static func build(
        from viewModel: CampaignViewModel,
        assignments: [PlayerAssignment] = [],
        revision: Int
    ) -> CampaignNetworkSnapshot {

        // Inventories: convert UUID keys to strings for Codable
        func mapInventory(_ dict: [UUID: [InventoryItem]]) -> [String: [NetworkInventoryItem]] {
            var result: [String: [NetworkInventoryItem]] = [:]
            for (key, items) in dict {
                result[key.uuidString] = items.map { NetworkInventoryItem(from: $0) }
            }
            return result
        }

        return CampaignNetworkSnapshot(
            schemaVersion: CampaignNetworkSnapshot.currentSchemaVersion,
            snapshotID: UUID(),
            snapshotDate: Date(),
            revision: revision,
            state: CampaignReplicatedState(
                dataVersion: viewModel.dataVersion,
                assignments: assignments,
                combatents: viewModel.combatents.map { NetworkCombatent(from: $0) },
                rollHistory: viewModel.rollHistory.map { NetworkRollEntry(from: $0) },
                encounters: viewModel.encounters.map { NetworkEncounter(from: $0) },
                playerInventories: mapInventory(viewModel.playerInventories),
                monsterInventories: mapInventory(viewModel.monsterInventories),
                npcInventories: mapInventory(viewModel.npcInventories),
                wikiEntries: viewModel.wikiEntries.map { NetworkWikiEntry(from: $0) },
                lootItems: viewModel.lootItems.map { NetworkLootItem(from: $0) },
                spellEntries: viewModel.spellEntries.map { NetworkSpellEntry(from: $0) },
                assets: viewModel.assets.map { NetworkAsset(from: $0) },
                players: testPlayers.map { NetworkPlayerState(from: $0) },
                monsters: testMonsters.map { NetworkMonsterState(from: $0) },
                npcs: testNPCs.map { NetworkNPCState(from: $0) }
            )
        )
    }

    // MARK: - Apply

    static func apply(
        _ snapshot: CampaignNetworkSnapshot,
        to viewModel: CampaignViewModel
    ) {
        let state = snapshot.state

        // Collections
        viewModel.combatents = state.combatents.map { $0.toCombatent() }
        viewModel.rollHistory = state.rollHistory.map { $0.toRollEntry() }
        viewModel.encounters = state.encounters.map { $0.toEncounter() }
        viewModel.wikiEntries = state.wikiEntries.map { $0.toWikiEntry() }
        viewModel.lootItems = state.lootItems.map { $0.toLootItem() }
        viewModel.spellEntries = state.spellEntries.map { $0.toSpellEntry() }
        viewModel.assets = state.assets.map { $0.toAsset() }
        viewModel.networkAssignments = state.assignments

        // Inventories
        viewModel.playerInventories = mapInventoryBack(state.playerInventories)
        viewModel.monsterInventories = mapInventoryBack(state.monsterInventories)
        viewModel.npcInventories = mapInventoryBack(state.npcInventories)

        // Mutable entity state: update global arrays
        applyPlayerStates(state.players)
        applyMonsterStates(state.monsters)
        applyNPCStates(state.npcs)

        // Bump data version so sidebar/search refresh
        viewModel.dataVersion = state.dataVersion + 1

        // Preserve selection if still valid; clear if stale
        if let selectedID = viewModel.selectedItemID {
            let allIDs = Set(
                viewModel.combatents.map { "combatent-\($0.id.uuidString)" }
                + testPlayers.map { "player-\($0.id.uuidString)" }
                + testMonsters.map { "monster-\($0.id.uuidString)" }
                + testNPCs.map { "character-\($0.id.uuidString)" }
                + viewModel.wikiEntries.map { "wiki-\($0.id)" }
                + viewModel.lootItems.map { "loot-\($0.id)" }
                + viewModel.spellEntries.map { "spell-\($0.id)" }
                + viewModel.assets.map { "asset-\($0.id)" }
            )
            // Only clear if it looks like an entity ID that no longer exists
            if selectedID.contains("-") && !allIDs.contains(selectedID) {
                // Check if it's a structural ID like "players", "npcs", "wiki"
                let structuralIDs: Set<String> = [
                    "players", "npcs", "monsters", "characters", "other",
                    "encounters", "public-assets", "private-assets",
                    "wiki", "wiki-entries", "wiki-loot", "wiki-spells"
                ]
                if !structuralIDs.contains(selectedID) {
                    viewModel.selectedItemID = nil
                }
            }
        }

        // Clear initiative selection if combatent no longer exists
        if let combID = viewModel.selectedInitiativeCombatentID,
           !viewModel.combatents.contains(where: { $0.id == combID }) {
            viewModel.selectedInitiativeCombatentID = nil
        }
    }

    // MARK: - Private Helpers

    private static func mapInventoryBack(_ dict: [String: [NetworkInventoryItem]]) -> [UUID: [InventoryItem]] {
        var result: [UUID: [InventoryItem]] = [:]
        for (key, items) in dict {
            if let uuid = UUID(uuidString: key) {
                result[uuid] = items.map { $0.toInventoryItem() }
            }
        }
        return result
    }

    private static func applyPlayerStates(_ states: [NetworkPlayerState]) {
        for state in states {
            guard let idx = testPlayers.firstIndex(where: { $0.id == state.id }) else { continue }
            testPlayers[idx].currentHP = state.currentHP
            testPlayers[idx].abilityScores = state.abilityScores.toAbilityScores()
            testPlayers[idx].status = state.status?.map { $0.toStatusCondition() }
            testPlayers[idx].spellSlots = state.spellSlots.map { $0.toSpellSlot() }
            testPlayers[idx].initiative = state.initiative
            for (ai, networkAttack) in state.actions.enumerated() {
                guard ai < testPlayers[idx].actions.count else { break }
                testPlayers[idx].actions[ai].remainingUses = networkAttack.remainingUses
            }
        }
    }

    private static func applyMonsterStates(_ states: [NetworkMonsterState]) {
        for state in states {
            guard let idx = testMonsters.firstIndex(where: { $0.id == state.id }) else { continue }
            testMonsters[idx].currentHP = state.currentHP
            testMonsters[idx].abilityScores = state.abilityScores.toAbilityScores()
            testMonsters[idx].status = state.status?.map { $0.toStatusCondition() }
            testMonsters[idx].initiative = state.initiative
            for (ai, networkAttack) in state.actions.enumerated() {
                guard ai < testMonsters[idx].actions.count else { break }
                testMonsters[idx].actions[ai].remainingUses = networkAttack.remainingUses
            }
        }
    }

    private static func applyNPCStates(_ states: [NetworkNPCState]) {
        for state in states {
            guard let idx = testNPCs.firstIndex(where: { $0.id == state.id }) else { continue }
            testNPCs[idx].currentHP = state.currentHP
            testNPCs[idx].abilityScores = state.abilityScores.toAbilityScores()
            testNPCs[idx].status = state.status?.map { $0.toStatusCondition() }
            testNPCs[idx].spellSlots = state.spellSlots.map { $0.toSpellSlot() }
            testNPCs[idx].initiative = state.initiative
            for (ai, networkAttack) in state.actions.enumerated() {
                guard ai < testNPCs[idx].actions.count else { break }
                testNPCs[idx].actions[ai].remainingUses = networkAttack.remainingUses
            }
        }
    }
}
