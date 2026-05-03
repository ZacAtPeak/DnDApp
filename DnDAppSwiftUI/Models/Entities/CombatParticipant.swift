import Foundation

protocol CombatParticipant: Identifiable where ID == UUID {
    var name: String { get }
    var currentHP: Int { get }
    var maxHP: Int { get }
    var abilityScores: AbilityScores { get }
    var status: [StatusCondition]? { get }
    var spellSlots: [SpellSlot] { get }
}

extension Monster: CombatParticipant {
    var spellSlots: [SpellSlot] { [] }
}

extension NPC: CombatParticipant {}

extension PlayerCharacter: CombatParticipant {}
