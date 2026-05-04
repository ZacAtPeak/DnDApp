import Foundation

// MARK: - Inventory & equipment

extension CampaignViewModel {
    var selectedPlayerInventory: [InventoryItem] {
        guard let id = selectedPlayer?.id else { return [] }
        return playerInventories[id] ?? []
    }

    var selectedMonsterInventory: [InventoryItem] {
        guard let id = selectedMonster?.id else { return [] }
        return monsterInventories[id] ?? []
    }

    var selectedNPCInventory: [InventoryItem] {
        guard let id = selectedNPC?.id else { return [] }
        return npcInventories[id] ?? []
    }

    func equippedModifiers(for entityID: UUID, entityType: InventoryEntityType) -> EquippedModifiers {
        let inv: [InventoryItem]
        switch entityType {
        case .player:  inv = playerInventories[entityID] ?? []
        case .monster: inv = monsterInventories[entityID] ?? []
        case .npc:     inv = npcInventories[entityID] ?? []
        }
        return lootItems.equippedModifiers(for: inv)
    }

    func toggleEquip(inventoryItemID: UUID, forEntity entityID: UUID, entityType: InventoryEntityType) {
        switch entityType {
        case .player:
            guard let idx = playerInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            playerInventories[entityID]![idx].isEquipped.toggle()
        case .monster:
            guard let idx = monsterInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            monsterInventories[entityID]![idx].isEquipped.toggle()
        case .npc:
            guard let idx = npcInventories[entityID]?.firstIndex(where: { $0.id == inventoryItemID }) else { return }
            npcInventories[entityID]![idx].isEquipped.toggle()
        }
    }
}
