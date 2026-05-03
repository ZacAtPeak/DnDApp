import Foundation

struct NPC: Identifiable {
    var id: UUID = UUID()

    var name: String
    var role: String
    var size: CreatureSize
    var alignment: Alignment
    var biography: String

    var armorClass: Int
    var armorSource: String
    var currentHP: Int
    var maxHP: Int
    var hitDice: String

    var speed: MovementSpeed

    var abilityScores: AbilityScores
    var proficiencyBonus: Int
    var savingThrowProficiencies: SavingThrowProficiencies
    var skills: [SkillProficiency]

    var damageResistances: [DamageType]
    var damageImmunities: [DamageType]
    var conditionImmunities: [String]

    var senses: Senses
    var languages: [String]

    var specialAbilities: [SpecialAbility]
    var actions: [Attack]
    var spellSlots: [SpellSlot]
    var knownSpells: [String] = []

    var initiative: Double = 0
    var status: [StatusCondition]?
}
