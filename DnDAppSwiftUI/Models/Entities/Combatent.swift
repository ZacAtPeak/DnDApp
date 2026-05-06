import Foundation

enum CombatentEntityType: String, Codable, Sendable {
    case player
    case monster
    case npc
}

struct Combatent: Identifiable {
    var id: UUID = UUID()
    var name: String
    var currentHP: Int
    var maxHP: Int
    var temporaryHP: Int = 0
    var initiative: Double
    var isTurn: Bool
    var status: [StatusCondition]?
    var creatureType: String? = nil
    var spellSlots: [SpellSlot]
    var speed: MovementSpeed
    var sourceSidebarID: String? = nil
    var sourceEntityID: UUID? = nil
    var sourceEntityType: CombatentEntityType? = nil
    var isLairAction: Bool = false
}
