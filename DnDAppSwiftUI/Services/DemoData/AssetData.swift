import Foundation

let assetDemoData: [Asset] = [
    // Public Assets
    Asset(
        id: "asset-tavern-commons",
        name: "The Wandering Wyvern",
        type: .location,
        description: "A bustling tavern in the heart of the city where adventurers gather for ales and information. Known for its colorful barkeep and the bulletin board of odd jobs.",
        isPublic: true,
        location: "Capital City",
        difficulty: "Social"
    ),
    Asset(
        id: "asset-forest-grove",
        name: "Whisperwood Grove",
        type: .location,
        description: "An ancient forest where fey creatures dwell. Magical glows illuminate the ancient trees at night, and strange sounds echo through the undergrowth.",
        isPublic: true,
        location: "The Realm Beyond",
        difficulty: "Dangerous"
    ),
    Asset(
        id: "asset-dungeon-crypt",
        name: "The Moldering Crypt",
        type: .dungeon,
        description: "A three-level underground necropolis rumored to house the treasures of a long-dead noble house. The air is thick with the stench of decay and magic.",
        isPublic: true,
        location: "North of Millstone",
        difficulty: "Hard",
        rewards: "Ancient artifacts, gold, spell scrolls"
    ),
    Asset(
        id: "asset-quest-dragon",
        name: "Scales of Green Mountain",
        type: .questHook,
        description: "Local villages report a green dragon has claimed residence in the mountain peaks. Livestock is disappearing, and fear spreads through the region.",
        isPublic: true,
        location: "The Spine Mountains",
        difficulty: "Legendary"
    ),
    Asset(
        id: "asset-faction-raven",
        name: "The Raven's Crown",
        type: .faction,
        description: "A shadowy thieves' guild operating in the shadows of the city. They control the black market and broker information for a price.",
        isPublic: true,
        location: "Capital City - Underground",
        difficulty: "Social"
    ),
    Asset(
        id: "asset-treasure-shipwreck",
        name: "The Siren's Graveyard",
        type: .treasureCache,
        description: "A merchant vessel wrecked on the rocky shoals, its cargo lost to the sea. Rumors speak of a legendary gem meant for a noble's ransom.",
        isPublic: true,
        location: "The Coastal Wastes",
        difficulty: "Moderate",
        rewards: "Gem of immense value, trade goods, rare components"
    ),

    // Private Assets
    Asset(
        id: "asset-plot-prophecy",
        name: "The Prophecy of the Void",
        type: .plot,
        description: "An ancient prophecy foretells of a darkness rising from beyond the veil between worlds. The party has inadvertently begun fulfilling its conditions.",
        isPublic: false,
        difficulty: "Secret",
        rewards: "Campaign climax revelation"
    ),
    Asset(
        id: "asset-npc-council",
        name: "The Archmagus Council",
        type: .npcGroup,
        description: "The seven most powerful mages in the realm. They maintain the wards that protect civilization from extraplanar incursions. One of them is secretly corrupted.",
        isPublic: false,
        location: "The Tower of Eternal Stars",
        difficulty: "Legendary"
    ),
    Asset(
        id: "asset-plot-traitor",
        name: "The Traitor in Their Midst",
        type: .plot,
        description: "One of the party's allies has been compromised by an ancient entity. They are slowly being subverted to act against the party's interests.",
        isPublic: false,
        difficulty: "Secret",
        rewards: "Reveals true loyalty and betrayal"
    ),
    Asset(
        id: "asset-dungeon-lair",
        name: "The Lich's Inner Sanctum",
        type: .dungeon,
        description: "Hidden deep within the Crypt of Souls lies the phylactery vault. The lich has prepared countless traps and undead guardians for those foolish enough to seek it.",
        isPublic: false,
        location: "Beneath the Moldering Crypt",
        difficulty: "Deadly",
        rewards: "Opportunity to destroy the lich permanently, powerful artifacts"
    ),
    Asset(
        id: "asset-faction-dragons",
        name: "The Chromatic Concord",
        type: .faction,
        description: "An alliance of evil dragons working to establish dominance over the realm. Their plans for conquest are advanced, and time is running out.",
        isPublic: false,
        location: "Various lairs across the realm",
        difficulty: "Apocalyptic"
    ),
    Asset(
        id: "asset-quest-artifact",
        name: "The Shattered Amulet of Korvash",
        type: .questHook,
        description: "A legendary artifact was shattered centuries ago and scattered across the realm. Gathering its pieces could grant power beyond mortal comprehension—or doom the world.",
        isPublic: false,
        location: "Multiple locations",
        difficulty: "Legendary",
        rewards: "Pieces of the amulet, ultimate power or ultimate sacrifice"
    ),
    Asset(
        id: "asset-map-underworld",
        name: "Map to the Shadowfell Portal",
        type: .map,
        description: "An ancient map showing the location of a hidden portal to the Shadowfell. The map itself is partially destroyed, requiring reconstruction from multiple sources.",
        isPublic: false,
        location: "Unknown",
        difficulty: "Mysterious",
        rewards: "Access to the Shadowfell, secrets of the shadow realm"
    )
]
