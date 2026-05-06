import Foundation

@MainActor
enum CampaignMutationReducer {
    enum ValidationError: Error {
        case rejected(code: String, reason: String)
    }

    /// Validates and applies a player update command against a mutable
    /// `CampaignReplicatedState`. Operates purely on the replicated state
    /// without touching global arrays or the view model directly.
    static func apply(
        _ command: PlayerCharacterUpdateCommand,
        from clientID: UUID,
        to state: inout CampaignReplicatedState,
        assignments: [PlayerAssignment]
    ) throws -> [CampaignDeltaChange] {
        guard let assignment = assignments.first(where: { $0.clientID == clientID }) else {
            throw ValidationError.rejected(code: "unassignedClient", reason: "Client has no player assignment")
        }

        guard command.playerID == assignment.playerCharacterID else {
            throw ValidationError.rejected(
                code: "wrongPlayerAssignment",
                reason: "Command targets a different player character"
            )
        }

        let playerIDString = command.playerID.uuidString
        guard let playerIndex = state.players.firstIndex(where: { UUID(uuidString: $0.id) == command.playerID }) else {
            throw ValidationError.rejected(code: "playerNotFound", reason: "Player character not found")
        }

        var changes: [CampaignDeltaChange] = []

        switch command {
        case .setHitPoints(_, let currentHP, let temporaryHP):
            let maxHP = state.players[playerIndex].maxHP
            let clampedHP = max(0, min(currentHP, maxHP))
            let clampedTempHP = max(0, temporaryHP)

            state.players[playerIndex] = NetworkPlayerState(
                id: state.players[playerIndex].id,
                name: state.players[playerIndex].name,
                currentHP: clampedHP,
                maxHP: state.players[playerIndex].maxHP,
                abilityScores: state.players[playerIndex].abilityScores,
                status: state.players[playerIndex].status,
                spellSlots: state.players[playerIndex].spellSlots,
                actions: state.players[playerIndex].actions,
                initiative: state.players[playerIndex].initiative
            )

            changes.append(.playerHitPointsChanged(
                playerID: command.playerID,
                currentHP: clampedHP,
                temporaryHP: clampedTempHP
            ))

            if let combIdx = state.combatents.firstIndex(where: {
                $0.sourceEntityID == command.playerID && $0.sourceEntityType == "player"
            }) {
                let existing = state.combatents[combIdx]
                state.combatents[combIdx] = NetworkCombatent(
                    id: existing.id, name: existing.name,
                    currentHP: clampedHP, maxHP: existing.maxHP,
                    temporaryHP: clampedTempHP, initiative: existing.initiative,
                    isTurn: existing.isTurn, status: existing.status,
                    creatureType: existing.creatureType,
                    spellSlots: existing.spellSlots, speed: existing.speed,
                    sourceSidebarID: existing.sourceSidebarID,
                    sourceEntityID: existing.sourceEntityID,
                    sourceEntityType: existing.sourceEntityType,
                    isLairAction: existing.isLairAction
                )
                changes.append(.combatentHitPointsChanged(
                    combatentID: existing.id,
                    currentHP: clampedHP,
                    temporaryHP: clampedTempHP
                ))
            }

        case .setStatuses(_, let statuses):
            let conditions = statuses
            state.players[playerIndex] = NetworkPlayerState(
                id: state.players[playerIndex].id,
                name: state.players[playerIndex].name,
                currentHP: state.players[playerIndex].currentHP,
                maxHP: state.players[playerIndex].maxHP,
                abilityScores: state.players[playerIndex].abilityScores,
                status: conditions,
                spellSlots: state.players[playerIndex].spellSlots,
                actions: state.players[playerIndex].actions,
                initiative: state.players[playerIndex].initiative
            )
            changes.append(.playerStatusesChanged(playerID: command.playerID, statuses: statuses))

            if let combIdx = state.combatents.firstIndex(where: {
                $0.sourceEntityID == command.playerID && $0.sourceEntityType == "player"
            }) {
                let existing = state.combatents[combIdx]
                state.combatents[combIdx] = NetworkCombatent(
                    id: existing.id, name: existing.name,
                    currentHP: existing.currentHP, maxHP: existing.maxHP,
                    temporaryHP: existing.temporaryHP, initiative: existing.initiative,
                    isTurn: existing.isTurn, status: conditions,
                    creatureType: existing.creatureType,
                    spellSlots: existing.spellSlots, speed: existing.speed,
                    sourceSidebarID: existing.sourceSidebarID,
                    sourceEntityID: existing.sourceEntityID,
                    sourceEntityType: existing.sourceEntityType,
                    isLairAction: existing.isLairAction
                )
                changes.append(.combatentStatusesChanged(
                    combatentID: existing.id,
                    statuses: statuses
                ))
            }

        case .setSpellSlot(_, let level, let available):
            guard level >= 1 && level <= 9 else {
                throw ValidationError.rejected(
                    code: "invalidSpellSlotLevel",
                    reason: "Invalid spell slot level \(level)"
                )
            }
            let existingPlayer = state.players[playerIndex]
            if let slotIdx = existingPlayer.spellSlots.firstIndex(where: { $0.level == level }) {
                let maxSlots = existingPlayer.spellSlots[slotIdx].max
                let clamped = max(0, min(available, maxSlots))
                var updatedSlots = existingPlayer.spellSlots
                updatedSlots[slotIdx] = NetworkSpellSlot(level: level, max: maxSlots, available: clamped)

                state.players[playerIndex] = NetworkPlayerState(
                    id: existingPlayer.id, name: existingPlayer.name,
                    currentHP: existingPlayer.currentHP, maxHP: existingPlayer.maxHP,
                    abilityScores: existingPlayer.abilityScores,
                    status: existingPlayer.status,
                    spellSlots: updatedSlots,
                    actions: existingPlayer.actions,
                    initiative: existingPlayer.initiative
                )
                changes.append(.playerSpellSlotChanged(playerID: command.playerID, level: level, available: clamped))

                if let combIdx = state.combatents.firstIndex(where: {
                    $0.sourceEntityID == command.playerID && $0.sourceEntityType == "player"
                }), let combatentSlotIdx = state.combatents[combIdx].spellSlots.firstIndex(where: { $0.level == level }) {
                    let existingCombatent = state.combatents[combIdx]
                    var updatedCombatentSlots = existingCombatent.spellSlots
                    updatedCombatentSlots[combatentSlotIdx] = NetworkSpellSlot(level: level, max: updatedCombatentSlots[combatentSlotIdx].max, available: clamped)
                    state.combatents[combIdx] = NetworkCombatent(
                        id: existingCombatent.id, name: existingCombatent.name,
                        currentHP: existingCombatent.currentHP, maxHP: existingCombatent.maxHP,
                        temporaryHP: existingCombatent.temporaryHP, initiative: existingCombatent.initiative,
                        isTurn: existingCombatent.isTurn, status: existingCombatent.status,
                        creatureType: existingCombatent.creatureType,
                        spellSlots: updatedCombatentSlots, speed: existingCombatent.speed,
                        sourceSidebarID: existingCombatent.sourceSidebarID,
                        sourceEntityID: existingCombatent.sourceEntityID,
                        sourceEntityType: existingCombatent.sourceEntityType,
                        isLairAction: existingCombatent.isLairAction
                    )
                    changes.append(.combatentSpellSlotChanged(
                        combatentID: existingCombatent.id,
                        level: level,
                        available: clamped
                    ))
                }
            }

        case .setActionUses(_, let actionIndex, let remainingUses):
            let existingPlayer = state.players[playerIndex]
            guard actionIndex >= 0 && actionIndex < existingPlayer.actions.count else {
                throw ValidationError.rejected(
                    code: "invalidActionIndex",
                    reason: "Invalid action index \(actionIndex)"
                )
            }
            if let maxUses = existingPlayer.actions[actionIndex].maxUses {
                let clamped = remainingUses.map { max(0, min($0, maxUses)) }
                var updatedActions = existingPlayer.actions
                let existingAction = updatedActions[actionIndex]
                updatedActions[actionIndex] = NetworkAttack(
                    id: existingAction.id, name: existingAction.name,
                    hitBonus: existingAction.hitBonus, reach: existingAction.reach,
                    damageRoll: existingAction.damageRoll, damageType: existingAction.damageType,
                    saveDC: existingAction.saveDC, description: existingAction.description,
                    maxUses: existingAction.maxUses, remainingUses: clamped
                )
                state.players[playerIndex] = NetworkPlayerState(
                    id: existingPlayer.id, name: existingPlayer.name,
                    currentHP: existingPlayer.currentHP, maxHP: existingPlayer.maxHP,
                    abilityScores: existingPlayer.abilityScores,
                    status: existingPlayer.status,
                    spellSlots: existingPlayer.spellSlots,
                    actions: updatedActions,
                    initiative: existingPlayer.initiative
                )
                changes.append(.playerActionUsesChanged(
                    playerID: command.playerID,
                    actionIndex: actionIndex,
                    remainingUses: clamped
                ))
            }

        case .setInventoryEquipped(_, let inventoryItemID, let isEquipped):
            let key = playerIDString
            if var items = state.playerInventories[key],
               let itemIdx = items.firstIndex(where: { $0.id == inventoryItemID }) {
                let existingItem = items[itemIdx]
                items[itemIdx] = NetworkInventoryItem(
                    id: existingItem.id,
                    lootItemID: existingItem.lootItemID,
                    isEquipped: isEquipped
                )
                state.playerInventories[key] = items
                changes.append(.playerInventoryItemEquippedChanged(
                    playerID: command.playerID,
                    inventoryItemID: inventoryItemID,
                    isEquipped: isEquipped
                ))
            } else {
                throw ValidationError.rejected(code: "inventoryItemNotFound", reason: "Inventory item not found")
            }

        case .submitRoll(_, let networkRoll):
            state.rollHistory.insert(networkRoll, at: 0)
            changes.append(.rollInserted(entry: networkRoll, position: "front"))
        }

        return changes
    }
}
