import Foundation

struct LootItem: Identifiable {
    let id: String
    let name: String
    let type: String
    let rarity: String
    let description: String
    var value: String?
    var requiresAttunement: Bool = false
    var properties: [String] = []
    var modifiers: [ItemModifier] = []
}
