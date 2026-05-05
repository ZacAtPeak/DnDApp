import Foundation

@MainActor
enum CampaignMutationReducer {
    enum ValidationError: Error {
        case rejected(code: String, reason: String)
    }

    static func apply(
        _ command: PlayerCharacterUpdateCommand,
        from clientID: UUID,
        to viewModel: CampaignViewModel,
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

        guard let playerIndex = testPlayers.firstIndex(where: { $0.id == command.playerID }) else {
            throw ValidationError.rejected(code: "playerNotFound", reason: "Player character not found")
        }

        var changes: [CampaignDeltaChange] = []

        switch command {
        case .setHitPoints(_, let currentHP, let temporaryHP):
            let maxHP = testPlayers[playerIndex].maxHP
            let clampedHP = max(0, min(currentHP, maxHP))
            let clampedTempHP = max(0, temporaryHP)
            testPlayers[playerIndex].currentHP = clampedHP
            changes.append(.playerHitPointsChanged(
                playerID: command.playerID,
                currentHP: clampedHP,
                temporaryHP: clampedTempHP
            ))

            if let combIdx = viewModel.combatents.firstIndex(where: {
                $0.sourceSidebarID == "player-\(command.playerID.uuidString)"
            }) {
                viewModel.combatents[combIdx].currentHP = clampedHP
                viewModel.combatents[combIdx].temporaryHP = clampedTempHP
                changes.append(.combatentHitPointsChanged(
                    combatentID: viewModel.combatents[combIdx].id,
                    currentHP: clampedHP,
                    temporaryHP: clampedTempHP
                ))
            }

        case .setStatuses(_, let statuses):
            let conditions = statuses.map { $0.toStatusCondition() }
            testPlayers[playerIndex].status = conditions.isEmpty ? nil : conditions
            changes.append(.playerStatusesChanged(playerID: command.playerID, statuses: statuses))

            if let combIdx = viewModel.combatents.firstIndex(where: {
                $0.sourceSidebarID == "player-\(command.playerID.uuidString)"
            }) {
                viewModel.combatents[combIdx].status = conditions.isEmpty ? nil : conditions
                changes.append(.combatentStatusesChanged(
                    combatentID: viewModel.combatents[combIdx].id,
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
            if let slotIdx = testPlayers[playerIndex].spellSlots.firstIndex(where: { $0.level == level }) {
                let maxSlots = testPlayers[playerIndex].spellSlots[slotIdx].max
                let clamped = max(0, min(available, maxSlots))
                testPlayers[playerIndex].spellSlots[slotIdx].available = clamped
                changes.append(.playerSpellSlotChanged(playerID: command.playerID, level: level, available: clamped))

                if let combIdx = viewModel.combatents.firstIndex(where: {
                    $0.sourceSidebarID == "player-\(command.playerID.uuidString)"
                }), let combatentSlotIdx = viewModel.combatents[combIdx].spellSlots.firstIndex(where: { $0.level == level }) {
                    viewModel.combatents[combIdx].spellSlots[combatentSlotIdx].available = clamped
                    changes.append(.combatentSpellSlotChanged(
                        combatentID: viewModel.combatents[combIdx].id,
                        level: level,
                        available: clamped
                    ))
                }
            }

        case .setActionUses(_, let actionIndex, let remainingUses):
            guard actionIndex >= 0 && actionIndex < testPlayers[playerIndex].actions.count else {
                throw ValidationError.rejected(
                    code: "invalidActionIndex",
                    reason: "Invalid action index \(actionIndex)"
                )
            }
            if let maxUses = testPlayers[playerIndex].actions[actionIndex].maxUses {
                let clamped = remainingUses.map { max(0, min($0, maxUses)) }
                testPlayers[playerIndex].actions[actionIndex].remainingUses = clamped
                changes.append(.playerActionUsesChanged(
                    playerID: command.playerID,
                    actionIndex: actionIndex,
                    remainingUses: clamped
                ))
            }

        case .setInventoryEquipped(_, let inventoryItemID, let isEquipped):
            if var items = viewModel.playerInventories[command.playerID],
               let itemIdx = items.firstIndex(where: { $0.id == inventoryItemID }) {
                items[itemIdx].isEquipped = isEquipped
                viewModel.playerInventories[command.playerID] = items
                changes.append(.playerInventoryItemEquippedChanged(
                    playerID: command.playerID,
                    inventoryItemID: inventoryItemID,
                    isEquipped: isEquipped
                ))
            } else {
                throw ValidationError.rejected(code: "inventoryItemNotFound", reason: "Inventory item not found")
            }

        case .submitRoll(_, let networkRoll):
            let roll = networkRoll.toRollEntry()
            viewModel.rollHistory.insert(roll, at: 0)
            viewModel.hasNewRollHistory = true
            changes.append(.rollInserted(entry: networkRoll, position: "front"))
        }

        return changes
    }
}
