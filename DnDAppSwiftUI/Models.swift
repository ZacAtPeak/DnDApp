//
//  Models.swift
//  DnDAppSwiftUI
//
//  Created by Zachary Reyes on 5/2/26.
//

import Foundation

// MARK: - Enums

enum DamageType: String, CaseIterable {
    case slashing, piercing, bludgeoning
    case fire, cold, lightning, thunder, acid, poison
    case necrotic, radiant, psychic, force
}

enum CreatureSize: String {
    case tiny = "Tiny"
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case huge = "Huge"
    case gargantuan = "Gargantuan"
}

enum CreatureType: String {
    case aberration = "Aberration"
    case beast = "Beast"
    case celestial = "Celestial"
    case construct = "Construct"
    case dragon = "Dragon"
    case elemental = "Elemental"
    case fey = "Fey"
    case fiend = "Fiend"
    case giant = "Giant"
    case humanoid = "Humanoid"
    case monstrosity = "Monstrosity"
    case ooze = "Ooze"
    case plant = "Plant"
    case undead = "Undead"
}

enum Alignment: String {
    case lawfulGood = "Lawful Good"
    case neutralGood = "Neutral Good"
    case chaoticGood = "Chaotic Good"
    case lawfulNeutral = "Lawful Neutral"
    case trueNeutral = "True Neutral"
    case chaoticNeutral = "Chaotic Neutral"
    case lawfulEvil = "Lawful Evil"
    case neutralEvil = "Neutral Evil"
    case chaoticEvil = "Chaotic Evil"
    case unaligned = "Unaligned"
}

// MARK: - Core Stats

struct AbilityScores {
    var strength: Int
    var dexterity: Int
    var constitution: Int
    var intelligence: Int
    var wisdom: Int
    var charisma: Int

    func modifier(for score: Int) -> Int { (score - 10) / 2 }
    var strMod: Int { modifier(for: strength) }
    var dexMod: Int { modifier(for: dexterity) }
    var conMod: Int { modifier(for: constitution) }
    var intMod: Int { modifier(for: intelligence) }
    var wisMod: Int { modifier(for: wisdom) }
    var chaMod: Int { modifier(for: charisma) }
}

struct MovementSpeed {
    var walk: Int
    var swim: Int? = nil
    var fly: Int? = nil
    var climb: Int? = nil
    var burrow: Int? = nil
    var hover: Bool = false
}

struct Senses {
    var darkvision: Int? = nil
    var blindsight: Int? = nil
    var tremorsense: Int? = nil
    var truesight: Int? = nil
    var passivePerception: Int
}

struct SavingThrowProficiencies {
    var strength: Bool = false
    var dexterity: Bool = false
    var constitution: Bool = false
    var intelligence: Bool = false
    var wisdom: Bool = false
    var charisma: Bool = false
}

struct SkillProficiency {
    var skill: String
    var bonus: Int
}

// An individual attack action with a to-hit roll and damage
struct Attack {
    var name: String
    var hitBonus: Int
    var reach: String       // "5 ft." or "80/320 ft."
    var damageRoll: String  // "2d6+4"
    var damageType: DamageType
    var description: String?
}

// Passive traits, breath weapons, and other non-attack abilities
struct SpecialAbility {
    var name: String
    var description: String
}

struct LegendaryAction {
    var name: String
    var cost: Int           // legendary action points consumed
    var description: String
}

// MARK: - Status & Spells

struct SpellSlot {
    var count: Int
    var level: Int
}

struct statusCondition {
    var name: String
    var effect: String
    var desc: String
}

// MARK: - Creature Types

struct Monster: Identifiable {
    var id: UUID = UUID()

    // Identity
    var name: String
    var size: CreatureSize
    var type: CreatureType
    var alignment: Alignment

    // Defense
    var armorClass: Int
    var armorSource: String         // e.g. "natural armor", "chain mail"
    var currentHP: Int
    var maxHP: Int
    var hitDice: String             // e.g. "10d8+20"

    // Movement
    var speed: MovementSpeed

    // Core Stats
    var abilityScores: AbilityScores
    var proficiencyBonus: Int
    var savingThrowProficiencies: SavingThrowProficiencies
    var skills: [SkillProficiency]

    // Damage Modifiers
    var damageVulnerabilities: [DamageType]
    var damageResistances: [DamageType]
    var damageImmunities: [DamageType]
    var conditionImmunities: [String]

    // Senses & Languages
    var senses: Senses
    var languages: [String]

    // Challenge
    var challengeRating: Double
    var xp: Int

    // Combat Abilities
    var specialAbilities: [SpecialAbility]
    var actions: [Attack]
    var legendaryActions: [LegendaryAction]?
    var legendaryActionCount: Int?

    // Encounter State
    var initiative: Double = 0
    var status: [statusCondition]?
}

struct NPC: Identifiable {
    var id: UUID = UUID()

    // Identity
    var name: String
    var role: String                // e.g. "Guard Captain", "Merchant"
    var size: CreatureSize
    var alignment: Alignment
    var biography: String

    // Defense
    var armorClass: Int
    var armorSource: String
    var currentHP: Int
    var maxHP: Int
    var hitDice: String

    // Movement
    var speed: MovementSpeed

    // Core Stats
    var abilityScores: AbilityScores
    var proficiencyBonus: Int
    var savingThrowProficiencies: SavingThrowProficiencies
    var skills: [SkillProficiency]

    // Damage Modifiers
    var damageResistances: [DamageType]
    var damageImmunities: [DamageType]
    var conditionImmunities: [String]

    // Senses & Languages
    var senses: Senses
    var languages: [String]

    // Combat Abilities
    var specialAbilities: [SpecialAbility]
    var actions: [Attack]
    var spellSlots: [SpellSlot]

    // Encounter State
    var initiative: Double = 0
    var status: [statusCondition]?
}

struct PlayerCharacter: Identifiable {
    var id: UUID = UUID()

    // Identity
    var name: String
    var race: String
    var playerClass: String
    var level: Int
    var background: String
    var size: CreatureSize
    var alignment: Alignment

    // Defense
    var armorClass: Int
    var armorSource: String
    var currentHP: Int
    var maxHP: Int
    var hitDice: String

    // Movement
    var speed: MovementSpeed

    // Core Stats
    var abilityScores: AbilityScores
    var proficiencyBonus: Int
    var savingThrowProficiencies: SavingThrowProficiencies
    var skills: [SkillProficiency]

    // Damage Modifiers
    var damageVulnerabilities: [DamageType]
    var damageResistances: [DamageType]
    var damageImmunities: [DamageType]
    var conditionImmunities: [String]

    // Senses & Languages
    var senses: Senses
    var languages: [String]

    // Abilities
    var specialAbilities: [SpecialAbility]
    var actions: [Attack]

    // Spells & Encounter State
    var spellSlots: [SpellSlot]
    var initiative: Double = 0
    var status: [statusCondition]?
}

struct Combatent: Identifiable {
    var id: UUID = UUID()
    var name: String
    var currentHP: Int
    var maxHP: Int
    var initiative: Double
    var isTurn: Bool
    var status: [statusCondition]?
    var spellSlotCount: Int
}

struct SidebarItem: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    var children: [SidebarItem]?
}

// MARK: - Demo Data

let testMonsters: [Monster] = [
    // 1. Goblin (CR 1/4)
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
        skills: [SkillProficiency(skill: "Stealth", bonus: 6)],
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

    // 2. Orc (CR 1/2)
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
        skills: [SkillProficiency(skill: "Intimidation", bonus: 2)],
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

    // 3. Troll (CR 5)
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
        skills: [SkillProficiency(skill: "Perception", bonus: 2)],
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

    // 4. Beholder (CR 13)
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
        skills: [SkillProficiency(skill: "Perception", bonus: 12)],
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

    // 5. Adult Red Dragon (CR 17)
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
        skills: [
            SkillProficiency(skill: "Perception", bonus: 13),
            SkillProficiency(skill: "Stealth", bonus: 6)
        ],
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

    // 6. Gelatinous Cube (CR 2)
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
        skills: [],
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
                description: "DC 12 DEX save or be engulfed. Engulfed creatures are restrained and blinded, take 6d6 acid damage at the start of each of the cube's turns."
            )
        ],
        initiative: -4
    ),

    // 7. Mimic (CR 2)
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
        skills: [SkillProficiency(skill: "Stealth", bonus: 5)],
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

    // 8. Skeleton (CR 1/4)
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
        skills: [],
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

    // 9. Zombie (CR 1/4)
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
        skills: [],
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

    // 10. Owlbear (CR 3)
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
        skills: [SkillProficiency(skill: "Perception", bonus: 3)],
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

let testNPCs: [NPC] = [
    // 1. Guard Captain (Fighter 8)
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

    // 2. Merchant & Informant (Rogue 5)
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

    // 3. Archmage (Wizard 9)
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

    // 4. Halfling Mayor
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

    // 5. Retired Adventurer / Barkeep (Barbarian 8)
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

let testPlayers: [PlayerCharacter] = [
    // 1. Aelar — Elf Wizard 4
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
            SpellSlot(count: 4, level: 1),
            SpellSlot(count: 3, level: 2)
        ],
        initiative: 12,
        status: [
            statusCondition(name: "Hasted", effect: "Speed Doubled", desc: "Gain an additional action each turn")
        ]
    ),

    // 2. Brakka — Half-Orc Barbarian 5
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

    // 3. Selene — Half-Elf Warlock 5
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
            SpellSlot(count: 4, level: 1),
            SpellSlot(count: 2, level: 2),
            SpellSlot(count: 2, level: 3)
        ],
        initiative: 8,
        status: [
            statusCondition(name: "Invisible", effect: "Unseen", desc: "Cannot be seen without special senses")
        ]
    ),

    // 4. Torvin — Human Paladin 4
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
            SpellSlot(count: 3, level: 1)
        ],
        initiative: 10,
        status: [
            statusCondition(name: "Inspired", effect: "1d8", desc: "Can add inspiration to a roll")
        ]
    )
]

let testCombatents: [Combatent] = [
    Combatent(
        name: "Ranger",
        currentHP: 31,
        maxHP: 45,
        initiative: 18,
        isTurn: true,
        status: [
            statusCondition(name: "Blessed", effect: "+1d4", desc: "Bonus to attack rolls and saving throws"),
            statusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Disadvantage on attack rolls and ability checks")
        ],
        spellSlotCount: 0
    ),
    Combatent(
        name: "Cleric",
        currentHP: 27,
        maxHP: 38,
        initiative: 17,
        isTurn: false,
        status: [
            statusCondition(name: "Concentrating", effect: "Spirit Guardians", desc: "Maintaining concentration on a spell")
        ],
        spellSlotCount: 6
    ),
    Combatent(
        name: "Fighter",
        currentHP: 42,
        maxHP: 52,
        initiative: 14,
        isTurn: false,
        status: nil,
        spellSlotCount: 0
    ),
    Combatent(
        name: "Guard Captain",
        currentHP: 31,
        maxHP: 56,
        initiative: 15,
        isTurn: false,
        status: nil,
        spellSlotCount: 5
    ),
    Combatent(
        name: "Ogre",
        currentHP: 59,
        maxHP: 59,
        initiative: 12,
        isTurn: false,
        status: [
            statusCondition(name: "Restrained", effect: "Speed 0", desc: "Attack rolls against it have advantage")
        ],
        spellSlotCount: 0
    ),
    Combatent(
        name: "Goblin Archer",
        currentHP: 11,
        maxHP: 11,
        initiative: 19,
        isTurn: false,
        status: nil,
        spellSlotCount: 0
    ),
    Combatent(
        name: "Young Wyvern",
        currentHP: 84,
        maxHP: 110,
        initiative: 13,
        isTurn: false,
        status: [
            statusCondition(name: "Frightened", effect: "Disadvantage", desc: "Cannot move closer to the source of fear")
        ],
        spellSlotCount: 0
    )
]

let sidebarItems: [SidebarItem] = [
    SidebarItem(
        id: "players",
        title: "Players",
        systemImage: "person.2",
        children: testPlayers.map { player in
            SidebarItem(
                id: "player-\(player.id.uuidString)",
                title: player.name,
                systemImage: "person",
                children: nil
            )
        }
    ),
    SidebarItem(
        id: "npcs",
        title: "NPCs",
        systemImage: "person.3",
        children: [
            SidebarItem(id: "npc-monsters", title: "Monsters", systemImage: "ant", children: nil),
            SidebarItem(id: "npc-characters", title: "Characters", systemImage: "person.2", children: nil),
            SidebarItem(id: "npc-other", title: "Other", systemImage: "square.grid.2x2", children: nil)
        ]
    ),
    SidebarItem(id: "public-assets", title: "Public Assets", systemImage: "globe", children: nil),
    SidebarItem(id: "private-assets", title: "Private Assets", systemImage: "lock", children: nil)
]
