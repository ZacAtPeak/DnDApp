import Foundation

protocol CombatParticipant: Identifiable where ID == UUID {
    var name: String { get }
    var currentHP: Int { get }
    var maxHP: Int { get }
    var abilityScores: AbilityScores { get }
    var status: [StatusCondition]? { get }
    var spellSlotCount: Int { get }
}

extension Monster: CombatParticipant {
    var spellSlotCount: Int { 0 }
}

extension NPC: CombatParticipant {
    var spellSlotCount: Int { spellSlots.reduce(0) { $0 + $1.count } }
}

extension PlayerCharacter: CombatParticipant {
    var spellSlotCount: Int { spellSlots.reduce(0) { $0 + $1.count } }
}
