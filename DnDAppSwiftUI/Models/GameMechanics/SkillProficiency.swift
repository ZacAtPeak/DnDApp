import Foundation

struct SkillProficiency {
    var skill: String
    var isProficient: Bool
    var bonus: Int
    var abilityScore: String
}

struct SkillDefinition {
    let name: String
    let abilityScore: String
}

let allSkillDefinitions: [SkillDefinition] = [
    SkillDefinition(name: "Acrobatics", abilityScore: "DEX"),
    SkillDefinition(name: "Animal Handling", abilityScore: "WIS"),
    SkillDefinition(name: "Arcana", abilityScore: "INT"),
    SkillDefinition(name: "Athletics", abilityScore: "STR"),
    SkillDefinition(name: "Deception", abilityScore: "CHA"),
    SkillDefinition(name: "History", abilityScore: "INT"),
    SkillDefinition(name: "Insight", abilityScore: "WIS"),
    SkillDefinition(name: "Intimidation", abilityScore: "CHA"),
    SkillDefinition(name: "Investigation", abilityScore: "INT"),
    SkillDefinition(name: "Medicine", abilityScore: "WIS"),
    SkillDefinition(name: "Nature", abilityScore: "INT"),
    SkillDefinition(name: "Perception", abilityScore: "WIS"),
    SkillDefinition(name: "Performance", abilityScore: "CHA"),
    SkillDefinition(name: "Persuasion", abilityScore: "CHA"),
    SkillDefinition(name: "Religion", abilityScore: "INT"),
    SkillDefinition(name: "Sleight of Hand", abilityScore: "DEX"),
    SkillDefinition(name: "Stealth", abilityScore: "DEX"),
    SkillDefinition(name: "Survival", abilityScore: "WIS")
]

func makeAllSkills(
    abilityScores: AbilityScores,
    proficiencyBonus: Int,
    proficientNames: Set<String>
) -> [SkillProficiency] {
    allSkillDefinitions.map { def in
        let modifier: Int
        switch def.abilityScore {
        case "STR": modifier = abilityScores.strMod
        case "DEX": modifier = abilityScores.dexMod
        case "CON": modifier = abilityScores.conMod
        case "INT": modifier = abilityScores.intMod
        case "WIS": modifier = abilityScores.wisMod
        case "CHA": modifier = abilityScores.chaMod
        default: modifier = 0
        }
        let isProficient = proficientNames.contains(def.name)
        let bonus = modifier + (isProficient ? proficiencyBonus : 0)
        return SkillProficiency(
            skill: def.name,
            isProficient: isProficient,
            bonus: bonus,
            abilityScore: def.abilityScore
        )
    }
}
