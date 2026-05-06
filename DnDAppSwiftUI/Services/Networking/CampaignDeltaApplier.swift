import Foundation

@MainActor
enum CampaignDeltaApplier {

    /// Applies a delta to a mutable `CampaignReplicatedState`.
    static func apply(_ delta: CampaignDelta, to state: inout CampaignReplicatedState) {
        for change in delta.changes {
            apply(change, to: &state)
        }
    }

    /// Applies a single delta change to a mutable `CampaignReplicatedState`.
    static func apply(_ change: CampaignDeltaChange, to state: inout CampaignReplicatedState) {
        switch change {
        case .assignmentChanged(let assignment):
            state.assignments.removeAll { $0.clientID == assignment.clientID }
            state.assignments.append(assignment)

        case .playerHitPointsChanged(let playerID, let currentHP, let temporaryHP):
            if let playerIndex = state.players.firstIndex(where: { UUID(uuidString: $0.id) == playerID }) {
                let existing = state.players[playerIndex]
                state.players[playerIndex] = NetworkPlayerState(
                    id: existing.id, name: existing.name,
                    currentHP: currentHP, maxHP: existing.maxHP,
                    abilityScores: existing.abilityScores,
                    status: existing.status,
                    spellSlots: existing.spellSlots,
                    actions: existing.actions,
                    initiative: existing.initiative
                )
            }

        case .playerStatusesChanged(let playerID, let statuses):
            if let playerIndex = state.players.firstIndex(where: { UUID(uuidString: $0.id) == playerID }) {
                let existing = state.players[playerIndex]
                state.players[playerIndex] = NetworkPlayerState(
                    id: existing.id, name: existing.name,
                    currentHP: existing.currentHP, maxHP: existing.maxHP,
                    abilityScores: existing.abilityScores,
                    status: statuses,
                    spellSlots: existing.spellSlots,
                    actions: existing.actions,
                    initiative: existing.initiative
                )
            }

        case .playerSpellSlotChanged(let playerID, let level, let available):
            if let playerIndex = state.players.firstIndex(where: { UUID(uuidString: $0.id) == playerID }) {
                let existing = state.players[playerIndex]
                if let slotIndex = existing.spellSlots.firstIndex(where: { $0.level == level }) {
                    var updatedSlots = existing.spellSlots
                    updatedSlots[slotIndex] = NetworkSpellSlot(level: level, max: existing.spellSlots[slotIndex].max, available: available)
                    state.players[playerIndex] = NetworkPlayerState(
                        id: existing.id, name: existing.name,
                        currentHP: existing.currentHP, maxHP: existing.maxHP,
                        abilityScores: existing.abilityScores,
                        status: existing.status,
                        spellSlots: updatedSlots,
                        actions: existing.actions,
                        initiative: existing.initiative
                    )
                }
            }

        case .playerActionUsesChanged(let playerID, let actionIndex, let remainingUses):
            if let playerIndex = state.players.firstIndex(where: { UUID(uuidString: $0.id) == playerID }) {
                let existing = state.players[playerIndex]
                guard actionIndex >= 0, actionIndex < existing.actions.count else { return }
                var updatedActions = existing.actions
                let existingAction = updatedActions[actionIndex]
                updatedActions[actionIndex] = NetworkAttack(
                    id: existingAction.id, name: existingAction.name,
                    hitBonus: existingAction.hitBonus, reach: existingAction.reach,
                    damageRoll: existingAction.damageRoll, damageType: existingAction.damageType,
                    saveDC: existingAction.saveDC, description: existingAction.description,
                    maxUses: existingAction.maxUses, remainingUses: remainingUses
                )
                state.players[playerIndex] = NetworkPlayerState(
                    id: existing.id, name: existing.name,
                    currentHP: existing.currentHP, maxHP: existing.maxHP,
                    abilityScores: existing.abilityScores,
                    status: existing.status,
                    spellSlots: existing.spellSlots,
                    actions: updatedActions,
                    initiative: existing.initiative
                )
            }

        case .playerInventoryItemEquippedChanged(let playerID, let inventoryItemID, let isEquipped):
            let key = playerID.uuidString
            if var items = state.playerInventories[key],
               let itemIndex = items.firstIndex(where: { $0.id == inventoryItemID }) {
                let existingItem = items[itemIndex]
                items[itemIndex] = NetworkInventoryItem(
                    id: existingItem.id,
                    lootItemID: existingItem.lootItemID,
                    isEquipped: isEquipped
                )
                state.playerInventories[key] = items
            }

        case .combatentHitPointsChanged(let combatentID, let currentHP, let temporaryHP):
            if let combatentIndex = state.combatents.firstIndex(where: { $0.id == combatentID }) {
                let existing = state.combatents[combatentIndex]
                state.combatents[combatentIndex] = NetworkCombatent(
                    id: existing.id, name: existing.name,
                    currentHP: currentHP, maxHP: existing.maxHP,
                    temporaryHP: temporaryHP, initiative: existing.initiative,
                    isTurn: existing.isTurn, status: existing.status,
                    creatureType: existing.creatureType,
                    spellSlots: existing.spellSlots, speed: existing.speed,
                    sourceSidebarID: existing.sourceSidebarID,
                    sourceEntityID: existing.sourceEntityID,
                    sourceEntityType: existing.sourceEntityType,
                    isLairAction: existing.isLairAction
                )
            }

        case .combatentStatusesChanged(let combatentID, let statuses):
            if let combatentIndex = state.combatents.firstIndex(where: { $0.id == combatentID }) {
                let existing = state.combatents[combatentIndex]
                state.combatents[combatentIndex] = NetworkCombatent(
                    id: existing.id, name: existing.name,
                    currentHP: existing.currentHP, maxHP: existing.maxHP,
                    temporaryHP: existing.temporaryHP, initiative: existing.initiative,
                    isTurn: existing.isTurn, status: statuses,
                    creatureType: existing.creatureType,
                    spellSlots: existing.spellSlots, speed: existing.speed,
                    sourceSidebarID: existing.sourceSidebarID,
                    sourceEntityID: existing.sourceEntityID,
                    sourceEntityType: existing.sourceEntityType,
                    isLairAction: existing.isLairAction
                )
            }

        case .combatentSpellSlotChanged(let combatentID, let level, let available):
            if let combatentIndex = state.combatents.firstIndex(where: { $0.id == combatentID }) {
                let existing = state.combatents[combatentIndex]
                if let slotIndex = existing.spellSlots.firstIndex(where: { $0.level == level }) {
                    var updatedSlots = existing.spellSlots
                    updatedSlots[slotIndex] = NetworkSpellSlot(level: level, max: existing.spellSlots[slotIndex].max, available: available)
                    state.combatents[combatentIndex] = NetworkCombatent(
                        id: existing.id, name: existing.name,
                        currentHP: existing.currentHP, maxHP: existing.maxHP,
                        temporaryHP: existing.temporaryHP, initiative: existing.initiative,
                        isTurn: existing.isTurn, status: existing.status,
                        creatureType: existing.creatureType,
                        spellSlots: updatedSlots, speed: existing.speed,
                        sourceSidebarID: existing.sourceSidebarID,
                        sourceEntityID: existing.sourceEntityID,
                        sourceEntityType: existing.sourceEntityType,
                        isLairAction: existing.isLairAction
                    )
                }
            }

        case .rollInserted(let entry, let position):
            if position == "front" {
                state.rollHistory.insert(entry, at: 0)
            } else {
                state.rollHistory.append(entry)
            }
        }
    }
}
