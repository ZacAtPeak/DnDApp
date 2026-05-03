import Foundation

var wikiDemoData: [WikiEntry] = [
    WikiEntry(
        id: "advantage",
        title: "Advantage",
        description: "When you have advantage on a roll, you roll two d20s and use the higher result. Advantage is granted by favorable circumstances, class features, or spells. Having multiple sources of advantage does not stack — you still only roll twice."
    ),
    WikiEntry(
        id: "disadvantage",
        title: "Disadvantage",
        description: "When you have disadvantage on a roll, you roll two d20s and use the lower result. Disadvantage is imposed by unfavorable conditions, debilitating effects, or enemy abilities. If you have both advantage and disadvantage simultaneously, they cancel out and you roll normally."
    ),
    WikiEntry(
        id: "darkvision",
        title: "Darkvision",
        description: "A creature with darkvision can see in dim light within a specified range as if it were bright light, and in darkness within that range as if it were dim light. In darkness, darkvision only allows the creature to see in shades of gray — it cannot discern color."
    ),
    WikiEntry(
        id: "concentration",
        title: "Concentration",
        description: "Some spells require you to maintain concentration to keep their effect active. You can only concentrate on one spell at a time — casting another concentration spell ends the first. Taking damage while concentrating requires a Constitution saving throw (DC 10 or half the damage, whichever is higher) or the spell ends."
    ),
    WikiEntry(
        id: "saving-throw",
        title: "Saving Throw",
        description: "A saving throw represents an attempt to resist a spell, trap, poison, disease, or other harmful effect. Roll a d20 and add the relevant ability modifier plus your proficiency bonus (if proficient). The result must meet or beat the effect's difficulty class (DC) to succeed."
    ),
    WikiEntry(
        id: "proficiency-bonus",
        title: "Proficiency Bonus",
        description: "Your proficiency bonus is added to attack rolls, saving throws, ability checks, and spell save DCs when you are proficient. It starts at +2 at level 1 and increases at levels 5 (+3), 9 (+4), 13 (+5), and 17 (+6). All characters of the same level share the same proficiency bonus."
    ),
    WikiEntry(
        id: "spell-slots",
        title: "Spell Slots",
        description: "Spell slots are the resource spellcasters expend to cast spells of 1st level and higher. Each slot has a level, and you can use a higher-level slot to cast a lower-level spell, often with enhanced effects. Most spell slots are recovered on a long rest, though Warlocks recover their slots on a short rest."
    ),
    WikiEntry(
        id: "resistance",
        title: "Resistance",
        description: "A creature with resistance to a damage type takes only half damage from sources of that type. Resistance is applied after all other modifiers. Having resistance from multiple sources does not further reduce the damage — it still only halves it once."
    ),
    WikiEntry(
        id: "vulnerability",
        title: "Vulnerability",
        description: "A creature with vulnerability to a damage type takes double damage from sources of that type. This doubling is applied after all other modifiers. If a creature has both resistance and vulnerability to the same damage type, they cancel out and normal damage is taken."
    ),
    WikiEntry(
        id: "bonus-action",
        title: "Bonus Action",
        description: "A bonus action is a special action available through certain class features, spells, or other abilities. You can take one bonus action on your turn; if you have nothing that grants a bonus action, you cannot use one. Unlike actions, bonus actions are only available when a specific feature says so."
    ),
    WikiEntry(
        id: "reaction",
        title: "Reaction",
        description: "A reaction is an instant response to a trigger of some kind, which can occur on your turn or on another creature's turn. You can take only one reaction per round, and it recharges at the start of your next turn. The most common reaction is the opportunity attack."
    ),
    WikiEntry(
        id: "opportunity-attack",
        title: "Opportunity Attack",
        description: "When a hostile creature moves out of your reach without using the Disengage action, you can use your reaction to make one melee attack against it. The attack uses your normal attack action, including extra attacks from Extra Attack. Flying creatures that land provoke opportunity attacks as normal."
    )
]
