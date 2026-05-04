import Foundation

// MARK: - Entity creation

extension CampaignViewModel {
    func createPlayerCharacter(_ player: PlayerCharacter) {
        testPlayers.append(player)
        selectedItemID = "player-\(player.id.uuidString)"
    }

    func createWikiEntry(_ entry: WikiEntry) {
        var id = entry.id
        var suffix = 2
        while wikiEntries.contains(where: { $0.id == id }) {
            id = "\(entry.id)-\(suffix)"
            suffix += 1
        }
        let stored = id == entry.id ? entry : WikiEntry(id: id, title: entry.title, description: entry.description, aliases: entry.aliases)
        wikiEntries.append(stored)
        selectedItemID = "wiki-\(stored.id)"
    }

    func createLootItem(_ item: LootItem) {
        var id = item.id
        var suffix = 2
        while lootItems.contains(where: { $0.id == id }) {
            id = "\(item.id)-\(suffix)"
            suffix += 1
        }
        let stored: LootItem
        if id == item.id {
            stored = item
        } else {
            stored = LootItem(
                id: id,
                name: item.name,
                type: item.type,
                rarity: item.rarity,
                description: item.description,
                value: item.value,
                requiresAttunement: item.requiresAttunement,
                properties: item.properties,
                modifiers: item.modifiers
            )
        }
        lootItems.append(stored)
        selectedItemID = "loot-\(stored.id)"
    }

    func createEncounter(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let encounter = Encounter(name: trimmed)
        encounters.append(encounter)
        selectedItemID = "encounter-\(encounter.id.uuidString)"
    }

    func deleteEncounter(id: UUID) {
        encounters.removeAll { $0.id == id }
        if selectedItemID == "encounter-\(id.uuidString)" {
            selectedItemID = nil
        }
    }

    func removeMemberFromEncounter(encounterID: UUID, memberSidebarID: String) {
        guard let index = encounters.firstIndex(where: { $0.id == encounterID }) else { return }
        encounters[index].memberSidebarIDs.removeAll { $0 == memberSidebarID }
    }
}
