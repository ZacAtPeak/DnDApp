import Foundation

struct SearchResult: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let sidebarID: String
}

// MARK: - Cross-entity search

extension CampaignViewModel {
    var searchResults: [SearchResult] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard query.count >= 1 else { return [] }

        var results: [SearchResult] = []

        for monster in testMonsters {
            if monster.name.lowercased().contains(query) || monster.type.rawValue.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "monster-\(monster.id.uuidString)",
                    title: monster.name,
                    subtitle: "\(monster.type.rawValue) • CR \(monster.challengeRating)",
                    systemImage: "ant.fill",
                    sidebarID: "monster-\(monster.id.uuidString)"
                ))
            }
        }

        for npc in testNPCs {
            if npc.name.lowercased().contains(query) || npc.role.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "character-\(npc.id.uuidString)",
                    title: npc.name,
                    subtitle: npc.role,
                    systemImage: "person.fill",
                    sidebarID: "character-\(npc.id.uuidString)"
                ))
            }
        }

        for player in testPlayers {
            if player.name.lowercased().contains(query) || player.race.lowercased().contains(query) || player.playerClass.lowercased().contains(query) {
                results.append(SearchResult(
                    id: "player-\(player.id.uuidString)",
                    title: player.name,
                    subtitle: "\(player.race) \(player.playerClass) • Level \(player.level)",
                    systemImage: "person",
                    sidebarID: "player-\(player.id.uuidString)"
                ))
            }
        }

        for entry in wikiEntries {
            let matchesTitle = entry.title.lowercased().contains(query)
            let matchesDesc = entry.description.lowercased().contains(query)
            let matchesAlias = entry.aliases.contains { $0.lowercased().contains(query) }
            if matchesTitle || matchesDesc || matchesAlias {
                results.append(SearchResult(
                    id: "wiki-\(entry.id)",
                    title: entry.title,
                    subtitle: "Wiki",
                    systemImage: "doc.text",
                    sidebarID: "wiki-\(entry.id)"
                ))
            }
        }

        for item in lootItems {
            let matchesName = item.name.lowercased().contains(query)
            let matchesType = item.type.lowercased().contains(query)
            let matchesRarity = item.rarity.lowercased().contains(query)
            let matchesDesc = item.description.lowercased().contains(query)
            if matchesName || matchesType || matchesRarity || matchesDesc {
                results.append(SearchResult(
                    id: "loot-\(item.id)",
                    title: item.name,
                    subtitle: "\(item.type) • \(item.rarity)",
                    systemImage: "diamond",
                    sidebarID: "loot-\(item.id)"
                ))
            }
        }

        for asset in assets {
            let matchesName = asset.name.lowercased().contains(query)
            let matchesType = asset.type.rawValue.lowercased().contains(query)
            let matchesDesc = asset.description.lowercased().contains(query)
            if matchesName || matchesType || matchesDesc {
                let visibility = asset.isPublic ? "Public" : "Private"
                results.append(SearchResult(
                    id: "asset-\(asset.id)",
                    title: asset.name,
                    subtitle: "\(asset.type.rawValue) • \(visibility)",
                    systemImage: asset.isPublic ? "globe" : "lock.fill",
                    sidebarID: "asset-\(asset.id)"
                ))
            }
        }

        return results
    }
}
