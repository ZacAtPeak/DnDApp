import Foundation

let defaultStatusConditions: [StatusCondition] = [
    StatusCondition(name: "Blinded", effect: "Cannot see", desc: "Automatically fails sight-based checks. Attacks against the creature have advantage, and its attacks have disadvantage."),
    StatusCondition(name: "Charmed", effect: "Cannot harm charmer", desc: "Cannot attack the charmer or target them with harmful abilities. The charmer has advantage on social checks against it."),
    StatusCondition(name: "Deafened", effect: "Cannot hear", desc: "Automatically fails hearing-based checks."),
    StatusCondition(name: "Exhaustion", effect: "Cumulative penalties", desc: "Suffers cumulative penalties based on exhaustion level."),
    StatusCondition(name: "Frightened", effect: "Disadvantage", desc: "Has disadvantage on ability checks and attack rolls while the source of fear is in sight, and cannot willingly move closer."),
    StatusCondition(name: "Grappled", effect: "Speed 0", desc: "Speed becomes 0 and cannot benefit from bonuses to speed."),
    StatusCondition(name: "Incapacitated", effect: "No actions", desc: "Cannot take actions or reactions."),
    StatusCondition(name: "Invisible", effect: "Unseen", desc: "Cannot be seen without special senses. Attacks against it have disadvantage, and its attacks have advantage."),
    StatusCondition(name: "Paralyzed", effect: "Incapacitated", desc: "Cannot move or speak. Fails Strength and Dexterity saves. Attacks against it have advantage; nearby hits are critical hits."),
    StatusCondition(name: "Petrified", effect: "Transformed", desc: "Transformed into solid material, incapacitated, unaware, resistant to damage, and fails Strength and Dexterity saves."),
    StatusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Has disadvantage on attack rolls and ability checks."),
    StatusCondition(name: "Prone", effect: "On the ground", desc: "Can crawl or stand. Attacks against it have advantage within 5 feet and disadvantage from farther away."),
    StatusCondition(name: "Restrained", effect: "Speed 0", desc: "Speed becomes 0. Attacks against it have advantage, its attacks have disadvantage, and it has disadvantage on Dexterity saves."),
    StatusCondition(name: "Stunned", effect: "Incapacitated", desc: "Cannot move, can speak only falteringly, fails Strength and Dexterity saves, and attacks against it have advantage."),
    StatusCondition(name: "Unconscious", effect: "Incapacitated", desc: "Drops prone, cannot move or speak, is unaware, fails Strength and Dexterity saves, and nearby hits are critical hits.")
]
