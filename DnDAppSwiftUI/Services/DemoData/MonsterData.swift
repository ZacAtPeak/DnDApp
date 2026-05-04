import Foundation

let testMonsters: [Monster] = [
    Monster(
        name: "Goblin",
        size: .small,
        type: .humanoid,
        alignment: .neutralEvil,
        armorClass: 15,
        armorSource: "leather armor, shield",
        currentHP: 7,
        maxHP: 7,
        hitDice: "2d6",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 8, dexterity: 14, constitution: 10, intelligence: 10, wisdom: 8, charisma: 8),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 8, dexterity: 14, constitution: 10, intelligence: 10, wisdom: 8, charisma: 8),
            proficiencyBonus: 2,
            proficientNames: ["Stealth"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 9),
        languages: ["Common", "Goblin"],
        challengeRating: 0.25,
        xp: 50,
        specialAbilities: [
            SpecialAbility(
                name: "Nimble Escape",
                description: "Can take the Disengage or Hide action as a bonus action on each of its turns."
            )
        ],
        actions: [
            Attack(name: "Scimitar", hitBonus: 4, reach: "5 ft.", damageRoll: "1d6+2", damageType: .slashing),
            Attack(name: "Shortbow", hitBonus: 4, reach: "80/320 ft.", damageRoll: "1d6+2", damageType: .piercing)
        ],
        initiative: 12
    ),

    Monster(
        name: "Orc",
        size: .medium,
        type: .humanoid,
        alignment: .chaoticEvil,
        armorClass: 13,
        armorSource: "hide armor",
        currentHP: 15,
        maxHP: 15,
        hitDice: "2d8+6",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 16, dexterity: 12, constitution: 16, intelligence: 7, wisdom: 11, charisma: 10),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 16, dexterity: 12, constitution: 16, intelligence: 7, wisdom: 11, charisma: 10),
            proficiencyBonus: 2,
            proficientNames: ["Intimidation"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 10),
        languages: ["Common", "Orc"],
        challengeRating: 0.5,
        xp: 100,
        specialAbilities: [
            SpecialAbility(
                name: "Aggressive",
                description: "As a bonus action, can move up to its speed toward a hostile creature it can see."
            )
        ],
        actions: [
            Attack(name: "Greataxe", hitBonus: 5, reach: "5 ft.", damageRoll: "1d12+3", damageType: .slashing),
            Attack(name: "Javelin", hitBonus: 5, reach: "5 ft. or 30/120 ft.", damageRoll: "1d6+3", damageType: .piercing)
        ],
        initiative: 2
    ),

    Monster(
        name: "Troll",
        size: .large,
        type: .giant,
        alignment: .chaoticEvil,
        armorClass: 15,
        armorSource: "natural armor",
        currentHP: 84,
        maxHP: 84,
        hitDice: "8d10+40",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 18, dexterity: 13, constitution: 20, intelligence: 7, wisdom: 9, charisma: 7),
        proficiencyBonus: 3,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 18, dexterity: 13, constitution: 20, intelligence: 7, wisdom: 9, charisma: 7),
            proficiencyBonus: 3,
            proficientNames: ["Perception"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 12),
        languages: ["Giant"],
        challengeRating: 5,
        xp: 1800,
        specialAbilities: [
            SpecialAbility(name: "Keen Smell", description: "Advantage on Perception checks that rely on smell."),
            SpecialAbility(
                name: "Regeneration",
                description: "Regains 10 HP at the start of its turn. Dies only if it starts its turn at 0 HP and fails to regenerate. Acid or fire damage suppresses regeneration until the start of its next turn."
            )
        ],
        actions: [
            Attack(name: "Bite", hitBonus: 7, reach: "5 ft.", damageRoll: "1d6+4", damageType: .piercing, description: "Multiattack: 1 bite + 2 claws"),
            Attack(name: "Claw", hitBonus: 7, reach: "5 ft.", damageRoll: "2d6+4", damageType: .slashing, description: "Multiattack: 1 bite + 2 claws")
        ],
        initiative: 2
    ),

    Monster(
        name: "Beholder",
        size: .large,
        type: .aberration,
        alignment: .lawfulEvil,
        armorClass: 18,
        armorSource: "natural armor",
        currentHP: 180,
        maxHP: 180,
        hitDice: "19d10+76",
        speed: MovementSpeed(walk: 0, fly: 20, hover: true),
        abilityScores: AbilityScores(strength: 10, dexterity: 14, constitution: 18, intelligence: 17, wisdom: 15, charisma: 17),
        proficiencyBonus: 5,
        savingThrowProficiencies: SavingThrowProficiencies(intelligence: true, wisdom: true, charisma: true),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 10, dexterity: 14, constitution: 18, intelligence: 17, wisdom: 15, charisma: 17),
            proficiencyBonus: 5,
            proficientNames: ["Perception"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: ["Prone"],
        senses: Senses(darkvision: 120, passivePerception: 22),
        languages: ["Deep Speech", "Undercommon"],
        challengeRating: 13,
        xp: 10000,
        specialAbilities: [
            SpecialAbility(
                name: "Antimagic Cone",
                description: "The central eye creates a 150-ft. cone of antimagic in front of it. Magic items, spells, and magical effects are suppressed in the cone and fail if targeted into it."
            ),
            SpecialAbility(
                name: "Eye Rays",
                description: "Shoots 3 random magical eye rays at up to 3 targets visible within 120 ft. Effects include charm, paralyze, fear, slow, enervation, telekinesis, sleep, petrification, disintegration, and death."
            )
        ],
        actions: [
            Attack(name: "Bite", hitBonus: 5, reach: "5 ft.", damageRoll: "4d6", damageType: .piercing)
        ],
        legendaryActions: [
            LegendaryAction(name: "Eye Ray", cost: 1, description: "Uses one random eye ray targeting one creature it can see within 120 ft.")
        ],
        legendaryActionCount: 3,
        initiative: 2
    ),

    Monster(
        name: "Adult Red Dragon",
        size: .huge,
        type: .dragon,
        alignment: .chaoticEvil,
        armorClass: 19,
        armorSource: "natural armor",
        currentHP: 256,
        maxHP: 256,
        hitDice: "19d12+114",
        speed: MovementSpeed(walk: 40, fly: 80, climb: 40),
        abilityScores: AbilityScores(strength: 27, dexterity: 10, constitution: 25, intelligence: 16, wisdom: 13, charisma: 21),
        proficiencyBonus: 6,
        savingThrowProficiencies: SavingThrowProficiencies(dexterity: true, constitution: true, wisdom: true, charisma: true),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 27, dexterity: 10, constitution: 25, intelligence: 16, wisdom: 13, charisma: 21),
            proficiencyBonus: 6,
            proficientNames: ["Perception", "Stealth"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [.fire],
        conditionImmunities: [],
        senses: Senses(darkvision: 120, blindsight: 60, passivePerception: 23),
        languages: ["Common", "Draconic"],
        challengeRating: 17,
        xp: 18000,
        specialAbilities: [
            SpecialAbility(name: "Legendary Resistance (3/Day)", description: "If the dragon fails a saving throw, it can choose to succeed instead."),
            SpecialAbility(
                name: "Fire Breath (Recharge 5–6)",
                description: "Exhales fire in a 60-ft. cone. DC 21 DEX save. On fail: 63 (18d6) fire damage. Half on success."
            )
        ],
        actions: [
            Attack(name: "Bite", hitBonus: 14, reach: "10 ft.", damageRoll: "2d10+8", damageType: .piercing, description: "Plus 4d6 fire damage. Multiattack: 1 bite + 2 claws"),
            Attack(name: "Claw", hitBonus: 14, reach: "5 ft.", damageRoll: "2d6+8", damageType: .slashing, description: "Multiattack: 1 bite + 2 claws"),
            Attack(name: "Tail", hitBonus: 14, reach: "15 ft.", damageRoll: "2d8+8", damageType: .bludgeoning)
        ],
        legendaryActions: [
            LegendaryAction(name: "Detect", cost: 1, description: "Makes a Perception check."),
            LegendaryAction(name: "Tail Attack", cost: 1, description: "Makes a tail attack."),
            LegendaryAction(name: "Wing Attack", cost: 2, description: "Beats wings. Creatures within 10 ft. must succeed DC 22 DEX save or take 2d6+8 bludgeoning and fall prone. Dragon can fly up to half its speed.")
        ],
        legendaryActionCount: 3,
        initiative: 8
    ),

    Monster(
        name: "Gelatinous Cube",
        size: .large,
        type: .ooze,
        alignment: .unaligned,
        armorClass: 6,
        armorSource: "",
        currentHP: 84,
        maxHP: 84,
        hitDice: "8d10+40",
        speed: MovementSpeed(walk: 15),
        abilityScores: AbilityScores(strength: 14, dexterity: 3, constitution: 20, intelligence: 1, wisdom: 6, charisma: 1),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 14, dexterity: 3, constitution: 20, intelligence: 1, wisdom: 6, charisma: 1),
            proficiencyBonus: 2,
            proficientNames: []
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: ["Blinded", "Charmed", "Deafened", "Exhaustion", "Frightened", "Prone"],
        senses: Senses(blindsight: 60, passivePerception: 8),
        languages: [],
        challengeRating: 2,
        xp: 450,
        specialAbilities: [
            SpecialAbility(name: "Ooze Cube", description: "The cube occupies its entire 10-ft. space. Other creatures can enter the space but are subjected to Engulf and can see through the cube's body."),
            SpecialAbility(name: "Transparent", description: "Even when visible, a DC 15 Perception check is required to spot it before entering its space.")
        ],
        actions: [
            Attack(name: "Pseudopod", hitBonus: 4, reach: "5 ft.", damageRoll: "3d6+2", damageType: .acid),
            Attack(
                name: "Engulf",
                hitBonus: 4,
                reach: "5 ft.",
                damageRoll: "6d6",
                damageType: .acid,
                saveDC: 12,
                description: "DC 12 DEX save or be engulfed. Engulfed creatures are restrained and blinded, take 6d6 acid damage at the start of each of the cube's turns."
            )
        ],
        initiative: -4
    ),

    Monster(
        name: "Mimic",
        size: .medium,
        type: .monstrosity,
        alignment: .trueNeutral,
        armorClass: 12,
        armorSource: "natural armor",
        currentHP: 58,
        maxHP: 58,
        hitDice: "9d8+18",
        speed: MovementSpeed(walk: 15),
        abilityScores: AbilityScores(strength: 17, dexterity: 12, constitution: 15, intelligence: 5, wisdom: 13, charisma: 8),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 17, dexterity: 12, constitution: 15, intelligence: 5, wisdom: 13, charisma: 8),
            proficiencyBonus: 2,
            proficientNames: ["Stealth"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [.acid],
        conditionImmunities: ["Prone"],
        senses: Senses(darkvision: 60, passivePerception: 11),
        languages: [],
        challengeRating: 2,
        xp: 450,
        specialAbilities: [
            SpecialAbility(name: "Shapechanger", description: "Can use its action to polymorph into an object or revert to its true form. Statistics are the same in each form."),
            SpecialAbility(name: "Adhesive (Object Form)", description: "Adheres to anything that touches it. Huge or smaller creatures are grappled (escape DC 13). Ability checks to escape disadvantage."),
            SpecialAbility(name: "False Appearance (Object Form)", description: "While motionless, indistinguishable from a mundane object."),
            SpecialAbility(name: "Grappler", description: "Advantage on attack rolls against any creature grappled by it.")
        ],
        actions: [
            Attack(name: "Pseudopod", hitBonus: 5, reach: "5 ft.", damageRoll: "1d8+3", damageType: .bludgeoning, description: "Target is subjected to the Adhesive trait."),
            Attack(name: "Bite", hitBonus: 5, reach: "5 ft.", damageRoll: "1d8+3", damageType: .piercing, description: "Plus 2d8 acid damage.")
        ],
        initiative: 10
    ),

    Monster(
        name: "Skeleton",
        size: .medium,
        type: .undead,
        alignment: .lawfulEvil,
        armorClass: 13,
        armorSource: "armor scraps",
        currentHP: 13,
        maxHP: 13,
        hitDice: "2d8+4",
        speed: MovementSpeed(walk: 30),
        abilityScores: AbilityScores(strength: 10, dexterity: 14, constitution: 15, intelligence: 6, wisdom: 8, charisma: 5),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 10, dexterity: 14, constitution: 15, intelligence: 6, wisdom: 8, charisma: 5),
            proficiencyBonus: 2,
            proficientNames: []
        ),
        damageVulnerabilities: [.bludgeoning],
        damageResistances: [],
        damageImmunities: [.poison],
        conditionImmunities: ["Exhaustion", "Poisoned"],
        senses: Senses(darkvision: 60, passivePerception: 9),
        languages: ["Understands languages it knew in life but can't speak"],
        challengeRating: 0.25,
        xp: 50,
        specialAbilities: [],
        actions: [
            Attack(name: "Shortsword", hitBonus: 4, reach: "5 ft.", damageRoll: "1d6+2", damageType: .piercing),
            Attack(name: "Shortbow", hitBonus: 4, reach: "80/320 ft.", damageRoll: "1d6+2", damageType: .piercing)
        ],
        initiative: 12
    ),

    Monster(
        name: "Zombie",
        size: .medium,
        type: .undead,
        alignment: .neutralEvil,
        armorClass: 8,
        armorSource: "",
        currentHP: 22,
        maxHP: 22,
        hitDice: "3d8+9",
        speed: MovementSpeed(walk: 20),
        abilityScores: AbilityScores(strength: 13, dexterity: 6, constitution: 16, intelligence: 3, wisdom: 6, charisma: 5),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(wisdom: true),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 13, dexterity: 6, constitution: 16, intelligence: 3, wisdom: 6, charisma: 5),
            proficiencyBonus: 2,
            proficientNames: []
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [.poison],
        conditionImmunities: ["Poisoned"],
        senses: Senses(darkvision: 60, passivePerception: 8),
        languages: ["Understands languages it knew in life but can't speak"],
        challengeRating: 0.25,
        xp: 50,
        specialAbilities: [
            SpecialAbility(
                name: "Undead Fortitude",
                description: "If damage reduces the zombie to 0 HP, it must make a CON save with DC 5 + damage dealt, unless the damage is radiant or a critical hit. On success, drops to 1 HP instead."
            )
        ],
        actions: [
            Attack(name: "Slam", hitBonus: 3, reach: "5 ft.", damageRoll: "1d6+1", damageType: .bludgeoning)
        ],
        initiative: -4
    ),

    Monster(
        name: "Owlbear",
        size: .large,
        type: .monstrosity,
        alignment: .unaligned,
        armorClass: 13,
        armorSource: "natural armor",
        currentHP: 59,
        maxHP: 59,
        hitDice: "7d10+21",
        speed: MovementSpeed(walk: 40),
        abilityScores: AbilityScores(strength: 20, dexterity: 12, constitution: 17, intelligence: 3, wisdom: 12, charisma: 7),
        proficiencyBonus: 2,
        savingThrowProficiencies: SavingThrowProficiencies(),
        skills: makeAllSkills(
            abilityScores: AbilityScores(strength: 20, dexterity: 12, constitution: 17, intelligence: 3, wisdom: 12, charisma: 7),
            proficiencyBonus: 2,
            proficientNames: ["Perception"]
        ),
        damageVulnerabilities: [],
        damageResistances: [],
        damageImmunities: [],
        conditionImmunities: [],
        senses: Senses(darkvision: 60, passivePerception: 13),
        languages: [],
        challengeRating: 3,
        xp: 700,
        specialAbilities: [
            SpecialAbility(name: "Keen Sight and Smell", description: "Advantage on Perception checks that rely on sight or smell.")
        ],
        actions: [
            Attack(name: "Beak", hitBonus: 7, reach: "5 ft.", damageRoll: "1d10+5", damageType: .piercing, description: "Multiattack: 1 beak + 1 talons"),
            Attack(name: "Talons", hitBonus: 7, reach: "5 ft.", damageRoll: "2d8+5", damageType: .slashing, description: "Multiattack: 1 beak + 1 talons")
        ],
        initiative: 2
    )
]
