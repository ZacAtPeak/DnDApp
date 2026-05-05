import SwiftUI
import Observation

enum InventoryEntityType { case player, monster, npc }

@Observable
@MainActor
final class CampaignViewModel {
    // MARK: - Sidebar / sheets / overlays

    var selectedItemID: String? = "players"
    var selectedInitiativeCombatentID: Combatent.ID?
    var isInitiativeTargeted = false
    var editingCombatentID: Combatent.ID?
    var isStatusPalettePresented = false
    var isLongRestConfirmationPresented = false
    var isCharacterCreationPresented = false
    var isWikiEntryCreationPresented = false
    var isLootCreationPresented = false
    var isEncounterCreationPresented = false
    var isPublicAssetCreationPresented = false
    var isPrivateAssetCreationPresented = false
    var isSearchPresented = false
    var searchQuery = ""
    var isRollHistoryPresented = false
    var isSettingsPresented = false
    var hasNewRollHistory = false
    var pendingStatus: StatusCondition?
    var dataVersion = 0

    // MARK: - Live data

    var wikiEntries: [WikiEntry] = wikiDemoData
    var lootItems: [LootItem] = lootDemoData
    var spellEntries: [SpellEntry] = spellDemoData
    var assets: [Asset] = assetDemoData
    var encounters: [Encounter] = []
    var playerInventories: [UUID: [InventoryItem]] = [:]
    var monsterInventories: [UUID: [InventoryItem]] = [:]
    var npcInventories: [UUID: [InventoryItem]] = [:]
    var combatents: [Combatent] = []
    var rollHistory: [RollEntry] = []

    // MARK: - Dependencies

    let dataService: CampaignDataService

    // MARK: - Networking

    @ObservationIgnored let networkingService = CampaignNetworkingService()
    @ObservationIgnored var networkAssignments: [PlayerAssignment] = []
    @ObservationIgnored var publishWorkItem: DispatchWorkItem?

    // MARK: - Init

    init(dataService: CampaignDataService) {
        self.dataService = dataService
        seedDemoInventories()
        seedDemoEncounters()
    }

    func seedDemoEncounters() {
        let monsterIDs = DemoDataStore.monsters
            .filter { ["Goblin", "Orc", "Skeleton", "Zombie", "Owlbear"].contains($0.name) }
            .map { "monster-\($0.id.uuidString)" }
        let playerIDs = DemoDataStore.players.map { "player-\($0.id.uuidString)" }
        encounters.append(
            Encounter(name: "Ambush at the Crossroads", memberSidebarIDs: playerIDs + monsterIDs)
        )
    }

    /// Seeds the per-entity inventories with the demo loadouts shown in the
    /// initial app state. Pulled out of `init` so the constructor stays tiny.
    func seedDemoInventories() {
        // Wizard (index 0): ring of protection equipped, bag of holding in pack
        if DemoDataStore.players.count > 0 {
            playerInventories[DemoDataStore.players[0].id] = [
                InventoryItem(lootItemID: "ring-of-protection", isEquipped: true),
                InventoryItem(lootItemID: "bag-of-holding")
            ]
        }
        // Barbarian (index 1): gauntlets equipped, potion in pack
        if DemoDataStore.players.count > 1 {
            playerInventories[DemoDataStore.players[1].id] = [
                InventoryItem(lootItemID: "gauntlets-of-ogre-power", isEquipped: true),
                InventoryItem(lootItemID: "potion-of-healing")
            ]
        }
        // Warlock (index 2): cloak and staff in pack
        if DemoDataStore.players.count > 2 {
            playerInventories[DemoDataStore.players[2].id] = [
                InventoryItem(lootItemID: "cloak-of-elvenkind"),
                InventoryItem(lootItemID: "staff-of-the-python")
            ]
        }
        // Paladin (index 3): dwarven thrower equipped, amulet of health equipped
        if DemoDataStore.players.count > 3 {
            playerInventories[DemoDataStore.players[3].id] = [
                InventoryItem(lootItemID: "dwarven-thrower", isEquipped: true),
                InventoryItem(lootItemID: "amulet-of-health", isEquipped: true)
            ]
        }
        // Guard Captain NPC (index 0): sword of vengeance equipped
        if DemoDataStore.npcs.count > 0 {
            npcInventories[DemoDataStore.npcs[0].id] = [
                InventoryItem(lootItemID: "sword-of-vengeance", isEquipped: true),
                InventoryItem(lootItemID: "ring-of-protection")
            ]
        }
        // Archmage NPC (index 2): staff equipped, deck of illusions in pack
        if DemoDataStore.npcs.count > 2 {
            npcInventories[DemoDataStore.npcs[2].id] = [
                InventoryItem(lootItemID: "staff-of-the-python", isEquipped: true),
                InventoryItem(lootItemID: "deck-of-illusions")
            ]
        }
    }
}
