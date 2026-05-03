import Foundation

let testCombatents: [Combatent] = [
    Combatent(
        name: "Ranger",
        currentHP: 31,
        maxHP: 45,
        initiative: 18,
        isTurn: true,
        status: [
            StatusCondition(name: "Blessed", effect: "+1d4", desc: "Bonus to attack rolls and saving throws"),
            StatusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Disadvantage on attack rolls and ability checks")
        ],
        creatureType: "Human",
        spellSlots: [],
        speed: MovementSpeed(walk: 30)
    ),
    Combatent(
        name: "Cleric",
        currentHP: 27,
        maxHP: 38,
        initiative: 17,
        isTurn: false,
        status: [
            StatusCondition(name: "Concentrating", effect: "Spirit Guardians", desc: "Maintaining concentration on a spell")
        ],
        creatureType: "Dwarf",
        spellSlots: [
            SpellSlot(level: 1, max: 4, available: 4),
            SpellSlot(level: 2, max: 3, available: 3),
            SpellSlot(level: 3, max: 2, available: 2),
            SpellSlot(level: 4, max: 0, available: 0),
            SpellSlot(level: 5, max: 0, available: 0),
            SpellSlot(level: 6, max: 0, available: 0),
            SpellSlot(level: 7, max: 0, available: 0),
            SpellSlot(level: 8, max: 0, available: 0),
            SpellSlot(level: 9, max: 0, available: 0)
        ],
        speed: MovementSpeed(walk: 25)
    ),
    Combatent(
        name: "Fighter",
        currentHP: 42,
        maxHP: 52,
        initiative: 14,
        isTurn: false,
        status: nil,
        creatureType: "Half-Orc",
        spellSlots: [],
        speed: MovementSpeed(walk: 30)
    ),
    Combatent(
        name: "Guard Captain",
        currentHP: 31,
        maxHP: 56,
        initiative: 15,
        isTurn: false,
        status: nil,
        creatureType: "Humanoid",
        spellSlots: [
            SpellSlot(level: 1, max: 4, available: 4),
            SpellSlot(level: 2, max: 3, available: 3),
            SpellSlot(level: 3, max: 0, available: 0),
            SpellSlot(level: 4, max: 0, available: 0),
            SpellSlot(level: 5, max: 0, available: 0),
            SpellSlot(level: 6, max: 0, available: 0),
            SpellSlot(level: 7, max: 0, available: 0),
            SpellSlot(level: 8, max: 0, available: 0),
            SpellSlot(level: 9, max: 0, available: 0)
        ],
        speed: MovementSpeed(walk: 30)
    ),
    Combatent(
        name: "Ogre",
        currentHP: 59,
        maxHP: 59,
        initiative: 12,
        isTurn: false,
        status: [
            StatusCondition(name: "Restrained", effect: "Speed 0", desc: "Attack rolls against it have advantage")
        ],
        creatureType: "Giant",
        spellSlots: [],
        speed: MovementSpeed(walk: 40)
    ),
    Combatent(
        name: "Goblin Archer",
        currentHP: 11,
        maxHP: 11,
        initiative: 19,
        isTurn: false,
        status: nil,
        creatureType: "Humanoid",
        spellSlots: [],
        speed: MovementSpeed(walk: 30)
    ),
    Combatent(
        name: "Young Wyvern",
        currentHP: 84,
        maxHP: 110,
        initiative: 13,
        isTurn: false,
        status: [
            StatusCondition(name: "Frightened", effect: "Disadvantage", desc: "Cannot move closer to the source of fear")
        ],
        creatureType: "Dragon",
        spellSlots: [],
        speed: MovementSpeed(walk: 30, fly: 80)
    )
]
