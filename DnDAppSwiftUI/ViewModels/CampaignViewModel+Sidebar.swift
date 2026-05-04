import SwiftUI

// MARK: - Sidebar tree & entity selection

extension CampaignViewModel {
    var sidebarItems: [SidebarItem] {
        [
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
            SidebarItem(id: "private-assets", title: "Private Assets", systemImage: "lock", children: nil),
            SidebarItem(
                id: "wiki",
                title: "Wiki",
                systemImage: "book.pages",
                children: [
                    SidebarItem(
                        id: "wiki-entries",
                        title: "Entries",
                        systemImage: "doc.text",
                        children: wikiEntries.map { entry in
                            SidebarItem(
                                id: "wiki-\(entry.id)",
                                title: entry.title,
                                systemImage: "doc.text",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(
                        id: "wiki-loot",
                        title: "Loot",
                        systemImage: "backpack",
                        children: lootItems.map { item in
                            SidebarItem(
                                id: "loot-\(item.id)",
                                title: item.name,
                                systemImage: "diamond",
                                children: nil
                            )
                        }
                    ),
                    SidebarItem(
                        id: "wiki-spells",
                        title: "Spells",
                        systemImage: "sparkles",
                        children: spellSidebarGroups()
                    )
                ]
            )
        ]
    }

    var selectedSidebarItem: SidebarItem? {
        dataService.sidebarItem(withID: selectedItemID, in: sidebarItems)
    }

    var selectedPlayer: PlayerCharacter? {
        dataService.player(for: selectedItemID)
    }

    var selectedMonster: Monster? {
        dataService.monster(for: selectedItemID)
    }

    var selectedNPC: NPC? {
        dataService.npc(for: selectedItemID)
    }

    var selectedWikiEntry: WikiEntry? {
        guard let id = selectedItemID, id.hasPrefix("wiki-") else { return nil }
        return wikiEntries.first { $0.id == String(id.dropFirst(5)) }
    }

    var selectedLootItem: LootItem? {
        guard let id = selectedItemID, id.hasPrefix("loot-") else { return nil }
        return lootItems.first { $0.id == String(id.dropFirst(5)) }
    }

    var selectedSpellEntry: SpellEntry? {
        guard let id = selectedItemID, id.hasPrefix("spell-") else { return nil }
        return spellEntries.first { $0.id == String(id.dropFirst(6)) }
    }

    func selectSidebarItem(_ id: String?) {
        selectedItemID = id
        selectedInitiativeCombatentID = nil
    }

    private func spellSidebarGroups() -> [SidebarItem] {
        let grouped = Dictionary(grouping: spellEntries, by: \.level)
        return (0...9).compactMap { level -> SidebarItem? in
            guard let spells = grouped[level], !spells.isEmpty else { return nil }
            let groupTitle = level == 0 ? "Cantrips" : "Level \(level.romanNumeral)"
            return SidebarItem(
                id: "wiki-spells-\(level)",
                title: groupTitle,
                systemImage: level == 0 ? "sparkle" : "sparkles",
                children: spells.map { spell in
                    SidebarItem(id: "spell-\(spell.id)", title: spell.name, systemImage: "sparkle", children: nil)
                }
            )
        }
    }
}
