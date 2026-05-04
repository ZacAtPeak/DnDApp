import Foundation

struct Asset: Identifiable {
    let id: String
    let name: String
    let type: AssetType
    let description: String
    let isPublic: Bool
    let location: String?
    let difficulty: String?
    let rewards: String?

    init(
        id: String,
        name: String,
        type: AssetType,
        description: String,
        isPublic: Bool = true,
        location: String? = nil,
        difficulty: String? = nil,
        rewards: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.description = description
        self.isPublic = isPublic
        self.location = location
        self.difficulty = difficulty
        self.rewards = rewards
    }
}

enum AssetType: String, CaseIterable {
    case location = "Location"
    case dungeon = "Dungeon"
    case questHook = "Quest Hook"
    case treasureCache = "Treasure Cache"
    case faction = "Faction"
    case plot = "Plot"
    case npcGroup = "NPC Group"
    case map = "Map"
}
