import Foundation

/// Immutable store of original demo data. All copies are captured at app launch
/// so they survive any removal/restore cycle.
enum DemoDataStore {
    // Private immutable backing stores — captured at load time, never mutated.
    private static let _players: [PlayerCharacter] = testPlayers
    private static let _monsters: [Monster] = testMonsters
    private static let _npcs: [NPC] = testNPCs

    static var players: [PlayerCharacter] { _players }
    static var monsters: [Monster] { _monsters }
    static var npcs: [NPC] { _npcs }

    // These are already immutable at the source, but we expose them consistently.
    static let wiki: [WikiEntry] = wikiDemoData
    static let loot: [LootItem] = lootDemoData
    static let spells: [SpellEntry] = spellDemoData
    static let assets: [Asset] = assetDemoData
}
