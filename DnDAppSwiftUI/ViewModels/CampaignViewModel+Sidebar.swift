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
            SidebarItem(
                id: "encounters",
                title: "Encounters",
                systemImage: "shield.lefthalf.filled",
                children: encounters.map { encounter in
                    SidebarItem(
                        id: "encounter-\(encounter.id.uuidString)",
                        title: encounter.name,
                        systemImage: "folder",
                        children: encounter.memberSidebarIDs.map { memberID in
                            SidebarItem(
                                id: "encounter-\(encounter.id.uuidString)-member-\(memberID)",
                                title: dataService.combatParticipant(for: memberID)?.name ?? "Unknown",
                                systemImage: iconForSidebarID(memberID),
                                children: nil
                            )
                        }
                    )
                }
            ),
            SidebarItem(
                id: "public-assets",
                title: "Public Assets",
                systemImage: "globe",
                children: assets.filter { $0.isPublic }.map { asset in
                    SidebarItem(
                        id: "asset-\(asset.id)",
                        title: asset.name,
                        systemImage: iconForAssetType(asset.type),
                        children: nil
                    )
                }
            ),
            SidebarItem(
                id: "private-assets",
                title: "Private Assets",
                systemImage: "lock",
                children: assets.filter { !$0.isPublic }.map { asset in
                    SidebarItem(
                        id: "asset-\(asset.id)",
                        title: asset.name,
                        systemImage: iconForAssetType(asset.type),
                        children: nil
                    )
                }
            ),
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

    var selectedAsset: Asset? {
        guard let id = selectedItemID, id.hasPrefix("asset-") else { return nil }
        return assets.first { $0.id == String(id.dropFirst(6)) }
    }

    func selectSidebarItem(_ id: String?) {
        if let id = id,
           id.hasPrefix("encounter-"),
           let memberRange = id.range(of: "-member-") {
            let memberID = String(id[memberRange.upperBound...])
            selectedItemID = memberID
            selectedInitiativeCombatentID = nil
            return
        }
        selectedItemID = id
        selectedInitiativeCombatentID = nil
    }

    private func iconForSidebarID(_ sidebarID: String) -> String {
        if sidebarID.hasPrefix("player-") { return "person" }
        if sidebarID.hasPrefix("monster-") { return "ant.fill" }
        if sidebarID.hasPrefix("character-") { return "person.fill" }
        return "questionmark"
    }

    private func iconForAssetType(_ type: AssetType) -> String {
        switch type {
        case .location: return "mappin"
        case .dungeon: return "cave.2"
        case .questHook: return "scroll"
        case .treasureCache: return "banknote"
        case .faction: return "star.fill"
        case .plot: return "books.vertical"
        case .npcGroup: return "person.3.fill"
        case .map: return "map"
        }
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
