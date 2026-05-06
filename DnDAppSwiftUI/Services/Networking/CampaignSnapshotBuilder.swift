import Foundation

// MARK: - Snapshot

/// Mutable canonical state container for the networking layer.
/// The reducer and applier operate on `inout CampaignReplicatedState`.
/// The view model syncs to/from this container via `CampaignSnapshotBuilder`.
nonisolated struct CampaignReplicatedState: Codable, Equatable, Sendable {
    var dataVersion: Int

    var assignments: [PlayerAssignment]
    var combatents: [NetworkCombatent]
    var rollHistory: [NetworkRollEntry]
    var encounters: [NetworkEncounter]
    var playerInventories: [String: [NetworkInventoryItem]]
    var monsterInventories: [String: [NetworkInventoryItem]]
    var npcInventories: [String: [NetworkInventoryItem]]
    var wikiEntries: [NetworkWikiEntry]
    var lootItems: [NetworkLootItem]
    var spellEntries: [NetworkSpellEntry]
    var assets: [NetworkAsset]
    var players: [NetworkPlayerState]
    var monsters: [NetworkMonsterState]
    var npcs: [NetworkNPCState]

    init(
        dataVersion: Int = 0,
        assignments: [PlayerAssignment] = [],
        combatents: [NetworkCombatent] = [],
        rollHistory: [NetworkRollEntry] = [],
        encounters: [NetworkEncounter] = [],
        playerInventories: [String: [NetworkInventoryItem]] = [:],
        monsterInventories: [String: [NetworkInventoryItem]] = [:],
        npcInventories: [String: [NetworkInventoryItem]] = [:],
        wikiEntries: [NetworkWikiEntry] = [],
        lootItems: [NetworkLootItem] = [],
        spellEntries: [NetworkSpellEntry] = [],
        assets: [NetworkAsset] = [],
        players: [NetworkPlayerState] = [],
        monsters: [NetworkMonsterState] = [],
        npcs: [NetworkNPCState] = []
    ) {
        self.dataVersion = dataVersion
        self.assignments = assignments
        self.combatents = combatents
        self.rollHistory = rollHistory
        self.encounters = encounters
        self.playerInventories = playerInventories
        self.monsterInventories = monsterInventories
        self.npcInventories = npcInventories
        self.wikiEntries = wikiEntries
        self.lootItems = lootItems
        self.spellEntries = spellEntries
        self.assets = assets
        self.players = players
        self.monsters = monsters
        self.npcs = npcs
    }
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

        func mapInventory(_ dict: [UUID: [InventoryItem]]) -> [String: [NetworkInventoryItem]] {
            var result: [String: [NetworkInventoryItem]] = [:]
            for (key, items) in dict {
                result[key.uuidString] = items.map { NetworkInventoryItem(from: $0) }
            }
            return result
        }

        let state = CampaignReplicatedState(
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

        return CampaignNetworkSnapshot(
            schemaVersion: CampaignNetworkSnapshot.currentSchemaVersion,
            snapshotID: UUID(),
            snapshotDate: Date(),
            revision: revision,
            state: state
        )
    }

    // MARK: - Apply

    static func apply(
        _ snapshot: CampaignNetworkSnapshot,
        to viewModel: CampaignViewModel
    ) {
        apply(snapshot.state, to: viewModel)
    }

    static func apply(
        _ state: CampaignReplicatedState,
        to viewModel: CampaignViewModel
    ) {
        viewModel.combatents = state.combatents.map { $0.toCombatent() }
        viewModel.rollHistory = state.rollHistory.map { $0.toRollEntry() }
        viewModel.encounters = state.encounters.map { $0.toEncounter() }
        viewModel.wikiEntries = state.wikiEntries.map { $0.toWikiEntry() }
        viewModel.lootItems = state.lootItems.map { $0.toLootItem() }
        viewModel.spellEntries = state.spellEntries.map { $0.toSpellEntry() }
        viewModel.assets = state.assets.map { $0.toAsset() }
        viewModel.networkAssignments = state.assignments

        viewModel.playerInventories = mapInventoryBack(state.playerInventories)
        viewModel.monsterInventories = mapInventoryBack(state.monsterInventories)
        viewModel.npcInventories = mapInventoryBack(state.npcInventories)

        applyPlayerStates(state.players)
        applyMonsterStates(state.monsters)
        applyNPCStates(state.npcs)

        viewModel.dataVersion = state.dataVersion + 1

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
            if selectedID.contains("-") && !allIDs.contains(selectedID) {
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

        if let combID = viewModel.selectedInitiativeCombatentID,
           !viewModel.combatents.contains(where: { $0.id == combID }) {
            viewModel.selectedInitiativeCombatentID = nil
        }
    }

    // MARK: - State Sync Helpers

    /// Read the current global + viewModel state into a CampaignReplicatedState.
    static func readCurrentState(from viewModel: CampaignViewModel, assignments: [PlayerAssignment]) -> CampaignReplicatedState {
        func mapInventory(_ dict: [UUID: [InventoryItem]]) -> [String: [NetworkInventoryItem]] {
            var result: [String: [NetworkInventoryItem]] = [:]
            for (key, items) in dict {
                result[key.uuidString] = items.map { NetworkInventoryItem(from: $0) }
            }
            return result
        }

        return CampaignReplicatedState(
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
    }

    /// Write a CampaignReplicatedState back to globals + viewModel.
    static func writeState(_ state: CampaignReplicatedState, to viewModel: CampaignViewModel) {
        apply(state, to: viewModel)
    }

    // MARK: - Entity Lookup in ReplicatedState

    static func playerIndex(in state: CampaignReplicatedState, playerID: UUID) -> Int? {
        state.players.firstIndex { UUID(uuidString: $0.id) == playerID }
    }

    static func combatentIndex(in state: CampaignReplicatedState, combatentID: UUID) -> Int? {
        state.combatents.firstIndex { $0.id == combatentID }
    }

    static func combatentIndexForPlayer(in state: CampaignReplicatedState, playerID: UUID) -> Int? {
        state.combatents.firstIndex { $0.sourceEntityID == playerID && $0.sourceEntityType == "player" }
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
            guard let id = UUID(uuidString: state.id),
                  let idx = testPlayers.firstIndex(where: { $0.id == id }) else { continue }
            testPlayers[idx].currentHP = state.currentHP
            testPlayers[idx].abilityScores = state.abilityScores.toAbilityScores()
            testPlayers[idx].status = state.status.map { $0.map { $0.toStatusCondition() } }
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
            guard let id = UUID(uuidString: state.id),
                  let idx = testMonsters.firstIndex(where: { $0.id == id }) else { continue }
            testMonsters[idx].currentHP = state.currentHP
            testMonsters[idx].abilityScores = state.abilityScores.toAbilityScores()
            testMonsters[idx].status = state.status.map { $0.map { $0.toStatusCondition() } }
            testMonsters[idx].initiative = state.initiative
            for (ai, networkAttack) in state.actions.enumerated() {
                guard ai < testMonsters[idx].actions.count else { break }
                testMonsters[idx].actions[ai].remainingUses = networkAttack.remainingUses
            }
        }
    }

    private static func applyNPCStates(_ states: [NetworkNPCState]) {
        for state in states {
            guard let id = UUID(uuidString: state.id),
                  let idx = testNPCs.firstIndex(where: { $0.id == id }) else { continue }
            testNPCs[idx].currentHP = state.currentHP
            testNPCs[idx].abilityScores = state.abilityScores.toAbilityScores()
            testNPCs[idx].status = state.status.map { $0.map { $0.toStatusCondition() } }
            testNPCs[idx].spellSlots = state.spellSlots.map { $0.toSpellSlot() }
            testNPCs[idx].initiative = state.initiative
            for (ai, networkAttack) in state.actions.enumerated() {
                guard ai < testNPCs[idx].actions.count else { break }
                testNPCs[idx].actions[ai].remainingUses = networkAttack.remainingUses
            }
        }
    }
}
