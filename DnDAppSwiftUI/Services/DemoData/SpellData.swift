import Foundation

let spellDemoData: [SpellEntry] = [
    // Cantrips
    SpellEntry(
        id: "fire-bolt",
        name: "Fire Bolt",
        level: 0,
        school: "Evocation",
        castingTime: "1 action",
        range: "120 feet",
        components: "V, S",
        duration: "Instantaneous",
        description: "You hurl a mote of fire at a creature or object within range. Make a ranged spell attack against the target. On a hit, the target takes 1d10 fire damage. A flammable object hit by this spell ignites if it isn't being worn or carried. The damage increases by 1d10 when you reach 5th level (2d10), 11th level (3d10), and 17th level (4d10).",
        damageRoll: "2d10",
        damageType: .fire
    ),
    SpellEntry(
        id: "prestidigitation",
        name: "Prestidigitation",
        level: 0,
        school: "Transmutation",
        castingTime: "1 action",
        range: "10 feet",
        components: "V, S",
        duration: "Up to 1 hour",
        description: "This spell is a minor magical trick that novice spellcasters use for practice. You create one of several minor magical effects within range: a harmless sensory effect, light or snuff a small flame, clean or soil an object no larger than 1 cubic foot, chill or warm or flavor up to 1 cubic foot of nonliving material, make a color, mark, or symbol appear on an object, or create a nonmagical trinket or illusory image. The effect lasts for up to 1 hour."
    ),
    SpellEntry(
        id: "eldritch-blast",
        name: "Eldritch Blast",
        level: 0,
        school: "Evocation",
        castingTime: "1 action",
        range: "120 feet",
        components: "V, S",
        duration: "Instantaneous",
        description: "A beam of crackling energy streaks toward a creature within range. Make a ranged spell attack against the target. On a hit, the target takes 1d10 force damage. The spell creates more than one beam when you reach higher levels: two beams at 5th level, three beams at 11th level, and four beams at 17th level. You can direct the beams at the same target or at different ones.",
        damageRoll: "2d10+4",
        damageType: .force
    ),

    // 1st level
    SpellEntry(
        id: "magic-missile",
        name: "Magic Missile",
        level: 1,
        school: "Evocation",
        castingTime: "1 action",
        range: "120 feet",
        components: "V, S",
        duration: "Instantaneous",
        description: "You create three glowing darts of magical force. Each dart hits a creature of your choice that you can see within range. A dart deals 1d4 + 1 force damage to its target. The darts all strike simultaneously and can be directed to hit one creature or several. When you cast this spell using a spell slot of 2nd level or higher, the spell creates one more dart for each slot level above 1st.",
        damageRoll: "3d4+3",
        damageType: .force
    ),
    SpellEntry(
        id: "cure-wounds",
        name: "Cure Wounds",
        level: 1,
        school: "Evocation",
        castingTime: "1 action",
        range: "Touch",
        components: "V, S",
        duration: "Instantaneous",
        description: "A creature you touch regains a number of hit points equal to 1d8 + your spellcasting ability modifier. This spell has no effect on undead or constructs. When you cast this spell using a spell slot of 2nd level or higher, the healing increases by 1d8 for each slot level above 1st.",
        damageRoll: "1d8"
    ),
    SpellEntry(
        id: "thunderwave",
        name: "Thunderwave",
        level: 1,
        school: "Evocation",
        castingTime: "1 action",
        range: "Self (15-foot cube)",
        components: "V, S",
        duration: "Instantaneous",
        description: "A wave of thunderous force sweeps out from you. Each creature in a 15-foot cube originating from you must make a Constitution saving throw. On a failed save, a creature takes 2d8 thunder damage and is pushed 10 feet away from you. On a successful save, the creature takes half as much damage and isn't pushed. The thunderclap can be heard out to 300 feet. When you cast this spell using a spell slot of 2nd level or higher, the damage increases by 1d8 for each slot level above 1st.",
        damageRoll: "2d8",
        damageType: .thunder,
        saveDC: 13
    ),

    SpellEntry(
        id: "mage-armor",
        name: "Mage Armor",
        level: 1,
        school: "Abjuration",
        castingTime: "1 action",
        range: "Touch",
        components: "V, S, M (a piece of cured leather)",
        duration: "8 hours",
        description: "You touch a willing creature who isn't wearing armor, and a magical force protects it until the spell ends. The target's base AC becomes 13 + its Dexterity modifier. The spell ends if the target dons armor or if you dismiss the spell as an action."
    ),
    SpellEntry(
        id: "shield",
        name: "Shield",
        level: 1,
        school: "Abjuration",
        castingTime: "1 reaction",
        range: "Self",
        components: "V, S",
        duration: "1 round",
        description: "An invisible barrier of magical force appears and protects you. Until the start of your next turn, you have a +5 bonus to AC, including against the triggering attack, and you take no damage from magic missile."
    ),
    SpellEntry(
        id: "burning-hands",
        name: "Burning Hands",
        level: 1,
        school: "Evocation",
        castingTime: "1 action",
        range: "Self (15-foot cone)",
        components: "V, S",
        duration: "Instantaneous",
        description: "As you hold your hands with thumbs touching and fingers spread, a thin sheet of flames shoots forth from your outstretched fingertips. Each creature in a 15-foot cone must make a Dexterity saving throw. A creature takes 3d6 fire damage on a failed save, or half as much damage on a successful one. The fire ignites any flammable objects in the area that aren't being worn or carried. When you cast this spell using a spell slot of 2nd level or higher, the damage increases by 1d6 for each slot level above 1st.",
        damageRoll: "3d6",
        damageType: .fire,
        saveDC: 13
    ),
    SpellEntry(
        id: "bless",
        name: "Bless",
        level: 1,
        school: "Enchantment",
        castingTime: "1 action",
        range: "30 feet",
        components: "V, S, M (a sprinkling of holy water)",
        duration: "Up to 1 minute",
        description: "You bless up to three creatures of your choice within range. Whenever a target makes an attack roll or a saving throw before the spell ends, the target can roll a d4 and add the number rolled to the attack roll or saving throw. When you cast this spell using a spell slot of 2nd level or higher, you can target one additional creature for each slot level above 1st.",
        concentration: true
    ),
    SpellEntry(
        id: "shield-of-faith",
        name: "Shield of Faith",
        level: 1,
        school: "Abjuration",
        castingTime: "1 bonus action",
        range: "60 feet",
        components: "V, S, M (a small parchment with a bit of holy text written on it)",
        duration: "Up to 10 minutes",
        description: "A shimmering field appears and surrounds a creature of your choice within range, granting it a +2 bonus to AC for the duration.",
        concentration: true
    ),
    SpellEntry(
        id: "wrathful-smite",
        name: "Wrathful Smite",
        level: 1,
        school: "Evocation",
        castingTime: "1 bonus action",
        range: "Self",
        components: "V",
        duration: "1 minute",
        description: "The next time you hit with a melee weapon attack during this spell's duration, your attack deals an extra 1d6 psychic damage. Additionally, if the target is a creature, it must make a Wisdom saving throw or be frightened of you until the spell ends. As an action, the creature can make a Wisdom check against your spell save DC to steel its resolve and end this spell on itself.",
        concentration: true,
        saveDC: 12
    ),

    // 2nd level
    SpellEntry(
        id: "misty-step",
        name: "Misty Step",
        level: 2,
        school: "Conjuration",
        castingTime: "1 bonus action",
        range: "Self",
        components: "V",
        duration: "Instantaneous",
        description: "Briefly surrounded by silvery mist, you teleport up to 30 feet to an unoccupied space that you can see."
    ),
    SpellEntry(
        id: "hold-person",
        name: "Hold Person",
        level: 2,
        school: "Enchantment",
        castingTime: "1 action",
        range: "60 feet",
        components: "V, S, M (a small, straight piece of iron)",
        duration: "Up to 1 minute",
        description: "Choose a humanoid that you can see within range. The target must succeed on a Wisdom saving throw or be paralyzed for the duration. At the end of each of its turns, the target can make another Wisdom saving throw. On a success, the spell ends on the target. When you cast this spell using a spell slot of 3rd level or higher, you can target one additional humanoid for each slot level above 2nd.",
        concentration: true,
        saveDC: 15
    ),

    // 3rd level
    SpellEntry(
        id: "fireball",
        name: "Fireball",
        level: 3,
        school: "Evocation",
        castingTime: "1 action",
        range: "150 feet",
        components: "V, S, M (a tiny ball of bat guano and sulfur)",
        duration: "Instantaneous",
        description: "A bright streak flashes from your pointing finger to a point you choose within range and then blossoms with a low roar into an explosion of flame. Each creature in a 20-foot-radius sphere centered on that point must make a Dexterity saving throw. A target takes 8d6 fire damage on a failed save, or half as much damage on a successful one. The fire spreads around corners. When you cast this spell using a spell slot of 4th level or higher, the damage increases by 1d6 for each slot level above 3rd.",
        damageRoll: "8d6",
        damageType: .fire,
        saveDC: 13
    ),
    SpellEntry(
        id: "counterspell",
        name: "Counterspell",
        level: 3,
        school: "Abjuration",
        castingTime: "1 reaction",
        range: "60 feet",
        components: "S",
        duration: "Instantaneous",
        description: "You attempt to interrupt a creature in the process of casting a spell. If the creature is casting a spell of 3rd level or lower, its spell fails and has no effect. If it is casting a spell of 4th level or higher, make an ability check using your spellcasting ability. The DC equals 10 + the spell's level. On a success, the creature's spell fails and has no effect. When you cast this spell using a spell slot of 4th level or higher, the interrupted spell automatically fails if its level is less than or equal to the level of the spell slot you used."
    ),

    SpellEntry(
        id: "hunger-of-hadar",
        name: "Hunger of Hadar",
        level: 3,
        school: "Conjuration",
        castingTime: "1 action",
        range: "150 feet",
        components: "V, S, M (a pickled octopus tentacle)",
        duration: "Up to 1 minute",
        description: "You open a gateway to the dark between the stars, a region infested with unknown horrors. A 20-foot-radius sphere of blackness and bitter cold appears, centered on a point with range and lasting for the duration. This void is filled with a cacophony of soft whispers and slurping noises that can be heard up to 30 feet away. No light, magical or otherwise, can illuminate the area, and creatures fully within the area are blinded. The void creates a warp in the fabric of space, and the area is difficult terrain. Any creature that starts its turn in the area takes 2d6 cold damage. Any creature that ends its turn in the area must succeed on a Dexterity saving throw or take 2d6 acid damage as milky, otherworldly tentacles rub against it.",
        concentration: true,
        saveDC: 15
    ),
    SpellEntry(
        id: "hypnotic-pattern",
        name: "Hypnotic Pattern",
        level: 3,
        school: "Illusion",
        castingTime: "1 action",
        range: "120 feet",
        components: "S, M (a glowing stick of incense or a crystal vial filled with phosphorescent material)",
        duration: "Up to 1 minute",
        description: "You create a twisting pattern of colors that weaves through the air inside a 30-foot cube within range. The pattern appears for a moment and vanishes. Each creature in the area who sees the pattern must make a Wisdom saving throw. On a failed save, the creature becomes charmed for the duration. While charmed by this spell, the creature is incapacitated and has a speed of 0. The spell ends for an affected creature if it takes any damage or if someone else uses an action to shake or slap the creature out of its stupor.",
        concentration: true,
        saveDC: 15
    ),

    // 4th level
    SpellEntry(
        id: "polymorph",
        name: "Polymorph",
        level: 4,
        school: "Transmutation",
        castingTime: "1 action",
        range: "60 feet",
        components: "V, S, M (a caterpillar cocoon)",
        duration: "Up to 1 hour",
        description: "This spell transforms a creature that you can see within range into a new form. An unwilling creature must make a Wisdom saving throw to avoid the effect. A shapechanger automatically succeeds on this saving throw. The transformation lasts for the duration, or until the target drops to 0 hit points or dies. The new form can be any beast whose challenge rating is equal to or less than the target's (or the target's level, if it doesn't have a challenge rating). The target's game statistics, including mental ability scores, are replaced by the statistics of the chosen beast.",
        concentration: true,
        saveDC: 13
    ),

    // 5th level
    SpellEntry(
        id: "wall-of-force",
        name: "Wall of Force",
        level: 5,
        school: "Evocation",
        castingTime: "1 action",
        range: "120 feet",
        components: "V, S, M (a pinch of powder made by crushing a clear gemstone)",
        duration: "Up to 10 minutes",
        description: "An invisible wall of force springs into existence at a point you choose within range. The wall appears in any orientation you choose — horizontally, vertically, or at an angle — and can float in the air, anchored to solid objects, or be formed into a hemisphere or sphere with a radius of up to 10 feet. The wall is 1/4 inch thick and lasts for the duration. The wall can be formed as a flat surface made up of ten 10-by-10-foot panels, or it can be formed into a hemisphere or sphere. Nothing can physically pass through the wall. It is immune to all damage and can't be dispelled by Dispel Magic.",
        concentration: true
    ),

    // 6th level
    SpellEntry(
        id: "chain-lightning",
        name: "Chain Lightning",
        level: 6,
        school: "Evocation",
        castingTime: "1 action",
        range: "150 feet",
        components: "V, S, M (a bit of fur, a piece of amber or a crystal rod, and three silver pins)",
        duration: "Instantaneous",
        description: "You create a bolt of lightning that arcs toward a target of your choice that you can see within range. Three bolts then leap from that target to as many as three other targets, each of which must be within 30 feet of the first target. A target can be a creature or an object and can be targeted by only one of the bolts. A target must make a Dexterity saving throw. The target takes 10d8 lightning damage on a failed save, or half as much damage on a successful one. When you cast this spell using a spell slot of 7th level or higher, one additional bolt leaps from the first target to another target for each slot level above 6th.",
        damageRoll: "10d8",
        damageType: .lightning,
        saveDC: 13
    ),

    // 7th level
    SpellEntry(
        id: "plane-shift",
        name: "Plane Shift",
        level: 7,
        school: "Conjuration",
        castingTime: "1 action",
        range: "Touch",
        components: "V, S, M (a forked, metal rod worth at least 250 gp attuned to a specific plane of existence)",
        duration: "Instantaneous",
        description: "You and up to eight willing creatures who link hands in a circle are transported to a different plane of existence. You can specify a target destination in general terms, such as the City of Brass on the Elemental Plane of Fire or the palace of Dispater on the second level of the Nine Hells, and you appear in or near that destination. Alternatively, if you know the sigil sequence of a teleportation circle on another plane of existence, this spell can take you to that circle. If the destination you describe isn't on the plane you specify, you appear in a random location on the named plane."
    ),

    // 8th level
    SpellEntry(
        id: "dominate-monster",
        name: "Dominate Monster",
        level: 8,
        school: "Enchantment",
        castingTime: "1 action",
        range: "60 feet",
        components: "V, S",
        duration: "Up to 1 hour",
        description: "You attempt to beguile a creature that you can see within range. It must succeed on a Wisdom saving throw or be charmed by you for the duration. If you or creatures that are friendly to you are fighting it, it has advantage on the saving throw. While the creature is charmed, you have a telepathic link with it as long as the two of you are on the same plane of existence. You can use this telepathic link to issue commands to the creature while you are conscious (no action required), which it does its best to obey.",
        concentration: true,
        saveDC: 13
    ),

    // 9th level
    SpellEntry(
        id: "wish",
        name: "Wish",
        level: 9,
        school: "Conjuration",
        castingTime: "1 action",
        range: "Self",
        components: "V",
        duration: "Instantaneous",
        description: "Wish is the mightiest spell a mortal creature can cast. By simply speaking aloud, you can alter the very foundations of reality in accord with your desires. You can duplicate any other spell of 8th level or lower. You don't need to meet any requirements in that spell, including costly components. Alternatively, you can create one of a number of other effects. Any effect other than duplicating a spell might place stress on you that causes you to age 1d10 years. Also, there is a 33 percent chance that you are unable to cast Wish ever again if you suffer this stress."
    ),
    SpellEntry(
        id: "time-stop",
        name: "Time Stop",
        level: 9,
        school: "Transmutation",
        castingTime: "1 action",
        range: "Self",
        components: "V",
        duration: "Instantaneous",
        description: "You briefly stop the flow of time for everyone but yourself. No time passes for other creatures, while you take 1d4 + 1 turns in a row, during which you can use actions and move as normal. This effect ends if one of the actions you use during this period, or any effects that you create during this period, affects a creature other than you or an object being worn or carried by someone other than you."
    )
]
