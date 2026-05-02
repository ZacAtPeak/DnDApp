import Foundation

struct Combatent: Identifiable {
    var id: UUID = UUID()
    var name: String
    var currentHP: Int
    var maxHP: Int
    var initiative: Double
    var isTurn: Bool
    var status: [StatusCondition]?
    var spellSlotCount: Int
    var creatureType: String? = nil
    var sourceSidebarID: String? = nil
}
