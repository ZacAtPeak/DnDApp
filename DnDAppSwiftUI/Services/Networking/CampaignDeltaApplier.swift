import Foundation

@MainActor
enum CampaignDeltaApplier {
    static func apply(_ delta: CampaignDelta, to viewModel: CampaignViewModel) {
        for change in delta.changes {
            apply(change, to: viewModel)
        }
    }

    static func apply(_ change: CampaignDeltaChange, to viewModel: CampaignViewModel) {
        switch change {
        case .assignmentChanged(let assignment):
            viewModel.networkAssignments.removeAll { $0.clientID == assignment.clientID }
            viewModel.networkAssignments.append(assignment)

        case .playerHitPointsChanged(let playerID, let currentHP, let temporaryHP):
            if let playerIndex = testPlayers.firstIndex(where: { $0.id == playerID }) {
                testPlayers[playerIndex].currentHP = currentHP
            }
            if let combatentIndex = viewModel.combatents.firstIndex(where: {
                $0.sourceSidebarID == "player-\(playerID.uuidString)"
            }) {
                viewModel.combatents[combatentIndex].currentHP = currentHP
                viewModel.combatents[combatentIndex].temporaryHP = temporaryHP
            }

        case .playerStatusesChanged(let playerID, let statuses):
            let converted = statuses.map { $0.toStatusCondition() }
            if let playerIndex = testPlayers.firstIndex(where: { $0.id == playerID }) {
                testPlayers[playerIndex].status = converted.isEmpty ? nil : converted
            }

        case .playerSpellSlotChanged(let playerID, let level, let available):
            if let playerIndex = testPlayers.firstIndex(where: { $0.id == playerID }),
               let slotIndex = testPlayers[playerIndex].spellSlots.firstIndex(where: { $0.level == level }) {
                testPlayers[playerIndex].spellSlots[slotIndex].available = available
            }

        case .playerActionUsesChanged(let playerID, let actionIndex, let remainingUses):
            if let playerIndex = testPlayers.firstIndex(where: { $0.id == playerID }),
               actionIndex >= 0, actionIndex < testPlayers[playerIndex].actions.count {
                testPlayers[playerIndex].actions[actionIndex].remainingUses = remainingUses
            }

        case .playerInventoryItemEquippedChanged(let playerID, let inventoryItemID, let isEquipped):
            if var items = viewModel.playerInventories[playerID],
               let itemIndex = items.firstIndex(where: { $0.id == inventoryItemID }) {
                items[itemIndex].isEquipped = isEquipped
                viewModel.playerInventories[playerID] = items
            }

        case .combatentHitPointsChanged(let combatentID, let currentHP, let temporaryHP):
            if let combatentIndex = viewModel.combatents.firstIndex(where: { $0.id == combatentID }) {
                viewModel.combatents[combatentIndex].currentHP = currentHP
                viewModel.combatents[combatentIndex].temporaryHP = temporaryHP
            }

        case .combatentStatusesChanged(let combatentID, let statuses):
            if let combatentIndex = viewModel.combatents.firstIndex(where: { $0.id == combatentID }) {
                let converted = statuses.map { $0.toStatusCondition() }
                viewModel.combatents[combatentIndex].status = converted.isEmpty ? nil : converted
            }

        case .combatentSpellSlotChanged(let combatentID, let level, let available):
            if let combatentIndex = viewModel.combatents.firstIndex(where: { $0.id == combatentID }),
               let slotIndex = viewModel.combatents[combatentIndex].spellSlots.firstIndex(where: { $0.level == level }) {
                viewModel.combatents[combatentIndex].spellSlots[slotIndex].available = available
            }

        case .rollInserted(let entry, let position):
            let roll = entry.toRollEntry()
            if position == "front" {
                viewModel.rollHistory.insert(roll, at: 0)
            } else {
                viewModel.rollHistory.append(roll)
            }
            viewModel.hasNewRollHistory = true
        }
    }
}
