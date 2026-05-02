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
        spellSlotCount: 0,
        creatureType: "Human"
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
        spellSlotCount: 6,
        creatureType: "Dwarf"
    ),
    Combatent(
        name: "Fighter",
        currentHP: 42,
        maxHP: 52,
        initiative: 14,
        isTurn: false,
        status: nil,
        spellSlotCount: 0,
        creatureType: "Half-Orc"
    ),
    Combatent(
        name: "Guard Captain",
        currentHP: 31,
        maxHP: 56,
        initiative: 15,
        isTurn: false,
        status: nil,
        spellSlotCount: 5,
        creatureType: "Humanoid"
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
        spellSlotCount: 0,
        creatureType: "Giant"
    ),
    Combatent(
        name: "Goblin Archer",
        currentHP: 11,
        maxHP: 11,
        initiative: 19,
        isTurn: false,
        status: nil,
        spellSlotCount: 0,
        creatureType: "Humanoid"
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
        spellSlotCount: 0,
        creatureType: "Dragon"
    )
]
