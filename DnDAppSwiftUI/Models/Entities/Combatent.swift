import Foundation

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
    var isLairAction: Bool = false
}
