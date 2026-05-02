import Foundation

struct Monster: Identifiable {
    var id: UUID = UUID()

    var name: String
    var size: CreatureSize
    var type: CreatureType
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

    var challengeRating: Double
    var xp: Int

    var specialAbilities: [SpecialAbility]
    var actions: [Attack]
    var legendaryActions: [LegendaryAction]?
    var legendaryActionCount: Int?

    var initiative: Double = 0
    var status: [StatusCondition]?
}
