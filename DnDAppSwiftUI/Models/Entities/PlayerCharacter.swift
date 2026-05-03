import Foundation

struct PlayerCharacter: Identifiable {
    var id: UUID = UUID()

    var name: String
    var race: String
    var playerClass: String
    var level: Int
    var background: String
    var size: CreatureSize
    var alignment: Alignment

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

    var damageVulnerabilities: [DamageType]
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
