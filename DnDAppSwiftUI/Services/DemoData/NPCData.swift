import Foundation

let testNPCs: [NPC] = [
    NPC(
        name: "Captain Alistair",
        role: "Guard Captain",
        size: .medium,
        alignment: .lawfulGood,
        biography: "The stern but fair captain of the city watch. Twenty years of service have hardened Alistair, but he still believes in justice above all else.",
        armorClass: 18,
        armorSource: "plate armor",
        currentHP: 52,
        maxHP: 52,
        hitDice: "8d8+16",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 16, dexterity: 12, constitution: 14, intelligence: 10, wisdom: 14, charisma: 14),
        proficiencyBonus: 3,
        savingThrowProficiencies: SavingThrowProficiencies(strength: true, constitution: true),
        skills: [
            SkillProficiency(skill: "Athletics", bonus: 6),
            SkillProficiency(skill: "Perception", bonus: 5),
            SkillProficiency(skill: "Intimidation", bonus: 5)
        ],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 15),
        languages: ["Common", "Elvish"],
        specialAbilities: [
            SpecialAbility(name: "Second Wind (1/Short Rest)", description: "Regain 1d10+8 HP as a bonus action."),
            SpecialAbility(name: "Action Surge (1/Short Rest)", description: "Take one additional action on your turn.")
        ],
        actions: [
            Attack(name: "Longsword", hitBonus: 6, reach: "5 ft.", damageRoll: "1d8+3", damageType: .slashing, description: "Versatile: 1d10+3"),
            Attack(name: "Shield Bash", hitBonus: 6, reach: "5 ft.", damageRoll: "1d4+3", damageType: .bludgeoning, description: "DC 14 STR save or target is knocked prone.")
        ],
        spellSlots: [],
        initiative: 5
    ),

    NPC(
        name: "Elara the Weaver",
        role: "Merchant & Informant",
        size: .medium,
        alignment: .trueNeutral,
        biography: "A local cloth merchant who knows every secret in town. Elara's nimble fingers are equally quick at threading a loom and picking a pocket.",
        armorClass: 13,
        armorSource: "leather armor",
        currentHP: 22,
        maxHP: 22,
        hitDice: "5d8",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 8, dexterity: 16, constitution: 10, intelligence: 14, wisdom: 12, charisma: 16),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(dexterity: true),
        skills: [
            SkillProficiency(skill: "Deception", bonus: 5),
            SkillProficiency(skill: "Stealth", bonus: 7),
            SkillProficiency(skill: "Insight", bonus: 3),
            SkillProficiency(skill: "Sleight of Hand", bonus: 7)
        ],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 11),
        languages: ["Common", "Elvish", "Thieves' Cant"],
        specialAbilities: [
            SpecialAbility(name: "Sneak Attack (3d6)", description: "Deals an extra 3d6 damage when attacking with advantage or when an ally is adjacent to the target."),
            SpecialAbility(name: "Cunning Action", description: "Can Dash, Disengage, or Hide as a bonus action.")
        ],
        actions: [
            Attack(name: "Dagger", hitBonus: 5, reach: "5 ft. or 20/60 ft.", damageRoll: "1d4+3", damageType: .piercing, description: "Plus 3d6 sneak attack damage"),
            Attack(name: "Hand Crossbow", hitBonus: 5, reach: "30/120 ft.", damageRoll: "1d6+3", damageType: .piercing)
        ],
        spellSlots: [],
        initiative: 10
    ),

    NPC(
        name: "Zalthar the Wise",
        role: "Archmage",
        size: .medium,
        alignment: .chaoticGood,
        biography: "An eccentric wizard living in a tower made entirely of glass. Zalthar has spent decades studying the arcane weave and claims to have met the gods — they all found him annoying.",
        armorClass: 12,
        armorSource: "mage armor",
        currentHP: 40,
        maxHP: 40,
        hitDice: "9d8",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 6, dexterity: 12, constitution: 12, intelligence: 20, wisdom: 16, charisma: 14),
        proficiencyBonus: 4,
        savingThrowProficiencies: SavingThrowProficiencies(intelligence: true, wisdom: true),
        skills: [
            SkillProficiency(skill: "Arcana", bonus: 13),
            SkillProficiency(skill: "History", bonus: 9),
            SkillProficiency(skill: "Insight", bonus: 7)
        ],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 13),
        languages: ["Common", "Elvish", "Draconic", "Infernal", "Celestial"],
        specialAbilities: [
            SpecialAbility(name: "Spellcasting (INT, save DC 17, +9 to hit)", description: "9th-level spellcaster. Prepared: fireball, counterspell, misty step, shield, magic missile, fly, dispel magic, and more."),
            SpecialAbility(name: "Arcane Recovery (1/Day)", description: "After a short rest, recover spell slots up to combined level 5.")
        ],
        actions: [
            Attack(name: "Quarterstaff", hitBonus: 2, reach: "5 ft.", damageRoll: "1d6-2", damageType: .bludgeoning),
            Attack(name: "Fire Bolt (Cantrip)", hitBonus: 9, reach: "120 ft.", damageRoll: "3d10", damageType: .fire)
        ],
        spellSlots: [
            SpellSlot(count: 4, level: 1),
            SpellSlot(count: 3, level: 2),
            SpellSlot(count: 3, level: 3),
            SpellSlot(count: 3, level: 4),
            SpellSlot(count: 1, level: 5)
        ],
        initiative: 8
    ),

    NPC(
        name: "Mayor Bumblefoot",
        role: "Mayor",
        size: .small,
        alignment: .neutralGood,
        biography: "The overly optimistic halfling mayor of Thornwick Village. Bumblefoot has governed for 12 years through sheer charm, good luck, and a very talented cook named Helga.",
        armorClass: 11,
        armorSource: "",
        currentHP: 18,
        maxHP: 18,
        hitDice: "4d6+4",
        speed: MovementSpeed(walk: 25),
        abilityScores: AbilityScores(strength: 8, dexterity: 12, constitution: 12, intelligence: 11, wisdom: 10, charisma: 18),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(charisma: true),
        skills: [
            SkillProficiency(skill: "Persuasion", bonus: 6),
            SkillProficiency(skill: "Insight", bonus: 4),
            SkillProficiency(skill: "History", bonus: 2)
        ],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 10),
        languages: ["Common", "Halfling"],
        specialAbilities: [
            SpecialAbility(name: "Halfling Luck", description: "When rolling a 1 on an attack, ability check, or saving throw, reroll the die and must use the new result."),
            SpecialAbility(name: "Inspiring Presence (1/Short Rest)", description: "As a bonus action, grant one creature within 30 ft. advantage on the next ability check or saving throw it makes.")
        ],
        actions: [
            Attack(name: "Walking Cane", hitBonus: 1, reach: "5 ft.", damageRoll: "1d4-1", damageType: .bludgeoning, description: "He really, truly does not want to fight.")
        ],
        spellSlots: [],
        initiative: 2
    ),

    NPC(
        name: "Barnaby the Barkeep",
        role: "Innkeeper & Retired Adventurer",
        size: .medium,
        alignment: .chaoticGood,
        biography: "A retired adventurer who runs the Rusty Tankard. Barnaby lost his left eye to a basilisk gaze and his right hand to a lich, but gained enough gold to buy the finest inn in the city. He still keeps a warhammer under the bar.",
        armorClass: 14,
        armorSource: "unarmored defense (CON)",
        currentHP: 52,
        maxHP: 52,
        hitDice: "8d8+16",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 16, dexterity: 14, constitution: 14, intelligence: 10, wisdom: 14, charisma: 15),
        proficiencyBonus: 3,
        savingThrowProficiencies: SavingThrowProficiencies(strength: true, dexterity: true),
        skills: [
            SkillProficiency(skill: "Athletics", bonus: 6),
            SkillProficiency(skill: "Perception", bonus: 5),
            SkillProficiency(skill: "Survival", bonus: 5)
        ],
        damageResistances: [.bludgeoning, .piercing, .slashing],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 15),
        languages: ["Common", "Dwarvish", "Giant"],
        specialAbilities: [
            SpecialAbility(name: "Rage (2/Day)", description: "Bonus action. Lasts 1 min. While raging: advantage on STR checks/saves, +3 melee damage, resistance to bludgeoning/piercing/slashing."),
            SpecialAbility(name: "Reckless Attack", description: "Advantage on all melee attacks this turn, but attackers gain advantage against him until next turn.")
        ],
        actions: [
            Attack(name: "Warhammer", hitBonus: 6, reach: "5 ft.", damageRoll: "1d8+3", damageType: .bludgeoning, description: "Versatile: 1d10+3. While raging: +3 damage."),
            Attack(name: "Unarmed Strike", hitBonus: 6, reach: "5 ft.", damageRoll: "1d4+3", damageType: .bludgeoning)
        ],
        spellSlots: [],
        initiative: 3
    )
]
