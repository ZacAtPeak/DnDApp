import Foundation

var testPlayers: [PlayerCharacter] = [
    PlayerCharacter(
        name: "Aelar",
        race: "High Elf",
        playerClass: "Wizard",
        level: 4,
        background: "Sage",
        size: .medium,
        alignment: .chaoticGood,
        armorClass: 12,
        armorSource: "Dexterity",
        currentHP: 34,
        maxHP: 41,
        hitDice: "4d6",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 8, dexterity: 14, constitution: 14, intelligence: 17, wisdom: 14, charisma: 10),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(intelligence: true, wisdom: true),
        skills: [
            SkillProficiency(skill: "Arcana", bonus: 5),
            SkillProficiency(skill: "History", bonus: 5),
            SkillProficiency(skill: "Perception", bonus: 4)
        ],
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 14),
        languages: ["Common", "Elvish", "Draconic"],
        specialAbilities: [
            SpecialAbility(name: "Spellcasting (INT, save DC 13, +5 to hit)", description: "4th-level spellcaster. Prepared: mage armor, magic missile, shield, burning hands, misty step."),
            SpecialAbility(name: "Fey Ancestry", description: "Advantage on saving throws against being charmed. Magic can't put Aelar to sleep."),
            SpecialAbility(name: "Arcane Recovery (1/Day)", description: "After a short rest, recover spell slots up to combined level 2.")
        ],
        actions: [
            Attack(name: "Dagger", hitBonus: 4, reach: "5 ft. or 20/60 ft.", damageRoll: "1d4+2", damageType: .piercing),
            Attack(name: "Fire Bolt (Cantrip)", hitBonus: 5, reach: "120 ft.", damageRoll: "2d10", damageType: .fire)
        ],
        spellSlots: [
            SpellSlot(level: 1, max: 4, available: 2),
            SpellSlot(level: 2, max: 3, available: 2)
        ],
        initiative: 12,
        status: [
            StatusCondition(name: "Hasted", effect: "Speed Doubled", desc: "Gain an additional action each turn")
        ]
    ),

    PlayerCharacter(
        name: "Brakka",
        race: "Half-Orc",
        playerClass: "Barbarian",
        level: 5,
        background: "Outlander",
        size: .medium,
        alignment: .chaoticNeutral,
        armorClass: 16,
        armorSource: "Unarmored Defense (CON)",
        currentHP: 52,
        maxHP: 52,
        hitDice: "5d12",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 18, dexterity: 14, constitution: 16, intelligence: 8, wisdom: 12, charisma: 10),
        proficiencyBonus: 3,
        savingThrowProficiencies: SavingThrowProficiencies(strength: true, constitution: true),
        skills: [
            SkillProficiency(skill: "Athletics", bonus: 7),
            SkillProficiency(skill: "Intimidation", bonus: 3),
            SkillProficiency(skill: "Survival", bonus: 4)
        ],
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 11),
        languages: ["Common", "Orc"],
        specialAbilities: [
            SpecialAbility(name: "Rage (3/Day)", description: "Bonus action. Lasts 1 min. +2 melee damage, advantage on STR checks/saves, resistance to bludgeoning/piercing/slashing."),
            SpecialAbility(name: "Reckless Attack", description: "Advantage on melee attacks this turn; attackers gain advantage against Brakka until next turn."),
            SpecialAbility(name: "Extra Attack", description: "Can attack twice whenever taking the Attack action."),
            SpecialAbility(name: "Relentless Endurance (1/Day)", description: "When reduced to 0 HP, drop to 1 HP instead."),
            SpecialAbility(name: "Savage Attacks", description: "On a critical hit with a melee weapon, roll one of the weapon's damage dice one additional time.")
        ],
        actions: [
            Attack(name: "Greataxe", hitBonus: 7, reach: "5 ft.", damageRoll: "1d12+4", damageType: .slashing, description: "While raging: +2 damage. Extra Attack."),
            Attack(name: "Handaxe", hitBonus: 7, reach: "5 ft. or 20/60 ft.", damageRoll: "1d6+4", damageType: .slashing)
        ],
        spellSlots: [],
        initiative: 14,
        status: nil
    ),

    PlayerCharacter(
        name: "Selene",
        race: "Half-Elf",
        playerClass: "Warlock",
        level: 5,
        background: "Charlatan",
        size: .medium,
        alignment: .trueNeutral,
        armorClass: 13,
        armorSource: "Leather Armor",
        currentHP: 26,
        maxHP: 33,
        hitDice: "5d8",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 8, dexterity: 16, constitution: 14, intelligence: 12, wisdom: 10, charisma: 18),
        proficiencyBonus: 3,
        savingThrowProficiencies: SavingThrowProficiencies(wisdom: true, charisma: true),
        skills: [
            SkillProficiency(skill: "Deception", bonus: 7),
            SkillProficiency(skill: "Arcana", bonus: 4),
            SkillProficiency(skill: "Insight", bonus: 3),
            SkillProficiency(skill: "Persuasion", bonus: 7)
        ],
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 10),
        languages: ["Common", "Elvish", "Infernal"],
        specialAbilities: [
            SpecialAbility(name: "Spellcasting (CHA, save DC 15, +7 to hit)", description: "Pact Magic: 2 spell slots, 3rd level, recover on short rest. Known: hunger of Hadar, hypnotic pattern, hold person, misty step."),
            SpecialAbility(name: "Fey Ancestry", description: "Advantage on saving throws against being charmed. Magic can't put Selene to sleep."),
            SpecialAbility(name: "Devil's Sight (Eldritch Invocation)", description: "Can see normally in darkness, both magical and nonmagical, to a distance of 120 ft."),
            SpecialAbility(name: "Agonizing Blast (Eldritch Invocation)", description: "Add CHA modifier (+4) to Eldritch Blast damage rolls.")
        ],
        actions: [
            Attack(name: "Eldritch Blast (Cantrip)", hitBonus: 7, reach: "120 ft.", damageRoll: "2d10+4", damageType: .force, description: "Two beams, each +7 to hit. Agonizing Blast adds +4 per beam."),
            Attack(name: "Dagger", hitBonus: 6, reach: "5 ft. or 20/60 ft.", damageRoll: "1d4+3", damageType: .piercing)
        ],
        spellSlots: [
            SpellSlot(level: 1, max: 4, available: 3),
            SpellSlot(level: 2, max: 2, available: 1),
            SpellSlot(level: 3, max: 2, available: 1)
        ],
        initiative: 8,
        status: [
            StatusCondition(name: "Invisible", effect: "Unseen", desc: "Cannot be seen without special senses")
        ]
    ),

    PlayerCharacter(
        name: "Torvin",
        race: "Human",
        playerClass: "Paladin",
        level: 4,
        background: "Noble",
        size: .medium,
        alignment: .lawfulGood,
        armorClass: 17,
        armorSource: "Half Plate + Shield",
        currentHP: 40,
        maxHP: 48,
        hitDice: "4d10",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 16, dexterity: 10, constitution: 14, intelligence: 10, wisdom: 12, charisma: 14),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(wisdom: true, charisma: true),
        skills: [
            SkillProficiency(skill: "Athletics", bonus: 5),
            SkillProficiency(skill: "Persuasion", bonus: 4),
            SkillProficiency(skill: "Insight", bonus: 3)
        ],
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(passivePerception: 11),
        languages: ["Common", "Celestial"],
        specialAbilities: [
            SpecialAbility(name: "Spellcasting (CHA, save DC 12, +4 to hit)", description: "Prepared: bless, cure wounds, shield of faith, wrathful smite."),
            SpecialAbility(name: "Divine Smite", description: "On a hit with a melee weapon, expend a spell slot to deal +2d8 radiant damage (3d8 on undead/fiends). +1d8 per slot level above 1st."),
            SpecialAbility(name: "Lay on Hands (20 pts/Day)", description: "Touch to restore HP from a pool of 20 points, or expend 5 to cure a disease or neutralize a poison."),
            SpecialAbility(name: "Aura of Protection", description: "Allies within 10 ft. add Torvin's CHA modifier (+2) to saving throws.")
        ],
        actions: [
            Attack(name: "Longsword", hitBonus: 5, reach: "5 ft.", damageRoll: "1d8+3", damageType: .slashing, description: "Versatile: 1d10+3."),
            Attack(name: "Shield Bash", hitBonus: 5, reach: "5 ft.", damageRoll: "1d4+3", damageType: .bludgeoning, description: "DC 13 STR save or target is knocked prone.")
        ],
        spellSlots: [
            SpellSlot(level: 1, max: 3, available: 1)
        ],
        initiative: 10,
        status: [
            StatusCondition(name: "Inspired", effect: "1d8", desc: "Can add inspiration to a roll")
        ]
    )
]
