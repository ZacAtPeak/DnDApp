import Foundation

var lootDemoData: [LootItem] = [
    LootItem(
        id: "bag-of-holding",
        name: "Bag of Holding",
        type: "Wondrous Item",
        rarity: "Uncommon",
        description: "This bag has an interior space considerably larger than its outside dimensions, roughly 2 feet in diameter at the mouth and 4 feet deep. The bag can hold up to 500 pounds, not exceeding a volume of 64 cubic feet. The bag weighs 15 pounds, regardless of its contents. Retrieving an item from the bag requires an action.",
        value: nil,
        requiresAttunement: false,
        properties: ["Holds 500 lbs", "64 cu ft capacity", "Always weighs 15 lbs"]
    ),
    LootItem(
        id: "cloak-of-elvenkind",
        name: "Cloak of Elvenkind",
        type: "Wondrous Item",
        rarity: "Uncommon",
        description: "While you wear this cloak with its hood up, Wisdom (Perception) checks made to see you have disadvantage, and you have advantage on Dexterity (Stealth) checks made to hide, as the cloak's color shifts to camouflage you. Pulling the hood up or down requires an action.",
        value: nil,
        requiresAttunement: true,
        properties: ["Disadvantage on Perception to see wearer", "Advantage on Stealth checks"]
    ),
    LootItem(
        id: "gauntlets-of-ogre-power",
        name: "Gauntlets of Ogre Power",
        type: "Wondrous Item",
        rarity: "Uncommon",
        description: "Your Strength score is 19 while you wear these gauntlets. They have no effect on you if your Strength is already 19 or higher without them.",
        value: nil,
        requiresAttunement: true,
        properties: ["Sets STR to 19"],
        modifiers: [.setAbilityScore("STR", 19)]
    ),
    LootItem(
        id: "potion-of-healing",
        name: "Potion of Healing",
        type: "Potion",
        rarity: "Common",
        description: "A character who drinks the magical red fluid in this vial regains 2d4 + 2 hit points. Drinking or administering a potion takes an action.",
        value: "50 gp",
        requiresAttunement: false,
        properties: ["Restores 2d4+2 HP", "Consumable"]
    ),
    LootItem(
        id: "ring-of-protection",
        name: "Ring of Protection",
        type: "Ring",
        rarity: "Rare",
        description: "You gain a +1 bonus to AC and saving throws while wearing this ring.",
        value: nil,
        requiresAttunement: true,
        properties: ["+1 AC", "+1 to saving throws"],
        modifiers: [.acBonus(1), .savingThrowBonus(1)]
    ),
    LootItem(
        id: "sword-of-vengeance",
        name: "Sword of Vengeance",
        type: "Weapon (any sword)",
        rarity: "Uncommon",
        description: "You gain a +1 bonus to attack and damage rolls made with this magic weapon. When you take damage from a creature within 5 feet of you, you must succeed on a DC 15 Wisdom saving throw or use your reaction to make one melee attack against that creature. Curse: This sword is cursed and possessed by a vengeful spirit.",
        value: nil,
        requiresAttunement: true,
        properties: ["+1 to attack and damage", "Cursed: must attack when damaged", "Berserker effect"],
        modifiers: [.attackBonus(1), .damageBonus(1)]
    ),
    LootItem(
        id: "staff-of-the-python",
        name: "Staff of the Python",
        type: "Staff",
        rarity: "Uncommon",
        description: "You can use an action to speak this staff's command word and throw the staff on the ground within 10 feet of you. The staff becomes a giant constrictor snake under your control and acts on its own initiative count. By using a bonus action to speak the command word again, you return the staff to its normal form in a space formerly occupied by the snake.",
        value: nil,
        requiresAttunement: true,
        properties: ["Transforms into giant constrictor snake", "Bonus action to revert"]
    ),
    LootItem(
        id: "amulet-of-health",
        name: "Amulet of Health",
        type: "Wondrous Item",
        rarity: "Rare",
        description: "Your Constitution score is 19 while you wear this amulet. It has no effect on you if your Constitution is already 19 or higher without it.",
        value: nil,
        requiresAttunement: true,
        properties: ["Sets CON to 19"],
        modifiers: [.setAbilityScore("CON", 19)]
    ),
    LootItem(
        id: "deck-of-illusions",
        name: "Deck of Illusions",
        type: "Wondrous Item",
        rarity: "Uncommon",
        description: "This box contains a set of parchment cards. A full deck has 34 cards. A card thrown at the ground becomes an illusion of a creature. The illusion lasts until it is dispelled. The illusory creature cannot move more than 10 feet from where the card landed, and cannot attack.",
        value: nil,
        requiresAttunement: false,
        properties: ["34 cards", "Creates illusory creatures", "Lasts until dispelled"]
    ),
    LootItem(
        id: "dwarven-thrower",
        name: "Dwarven Thrower",
        type: "Weapon (warhammer)",
        rarity: "Very Rare",
        description: "You gain a +3 bonus to attack and damage rolls made with this magic weapon. It has the thrown property with a normal range of 20 feet and a long range of 60 feet. When you hit with a ranged attack using this weapon, it deals an extra 1d8 damage, or 2d8 damage if the target is a giant.",
        value: nil,
        requiresAttunement: true,
        properties: ["+3 to attack and damage", "Thrown (20/60)", "Extra 1d8 damage (2d8 vs giants)"],
        modifiers: [.attackBonus(3), .damageBonus(3)]
    )
]
