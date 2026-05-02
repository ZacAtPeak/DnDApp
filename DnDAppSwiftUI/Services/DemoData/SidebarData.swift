import Foundation

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
            SidebarItem(
                id: "npc-monsters",
                title: "Monsters",
                systemImage: "ant",
                children: testMonsters.map { monster in
                    SidebarItem(
                        id: "monster-\(monster.id.uuidString)",
                        title: monster.name,
                        systemImage: "ant.fill",
                        children: nil
                    )
                }
            ),
            SidebarItem(
                id: "npc-characters",
                title: "Characters",
                systemImage: "person.2",
                children: testNPCs.map { npc in
                    SidebarItem(
                        id: "character-\(npc.id.uuidString)",
                        title: npc.name,
                        systemImage: "person.fill",
                        children: nil
                    )
                }
            ),
            SidebarItem(id: "npc-other", title: "Other", systemImage: "square.grid.2x2", children: nil)
        ]
    ),
    SidebarItem(id: "public-assets", title: "Public Assets", systemImage: "globe", children: nil),
    SidebarItem(id: "private-assets", title: "Private Assets", systemImage: "lock", children: nil)
]
