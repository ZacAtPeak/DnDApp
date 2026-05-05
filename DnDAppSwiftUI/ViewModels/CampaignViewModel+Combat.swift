import Foundation

// MARK: - Action use, spellcasting, long rest

extension CampaignViewModel {
    func useAction(_ action: Attack, forEntity entityID: UUID, entityType: InventoryEntityType, name: String) {
        var mutableAction = action
        if let remaining = mutableAction.remainingUses, remaining > 0 {
            mutableAction.remainingUses = remaining - 1
        }

        // Roll to-hit
        let toHitRoll = Int.random(in: 1...20)
        let toHitTotal = toHitRoll + action.hitBonus
        logRoll(type: "Action", name: "\(name) — \(action.name) (Attack)", roll: toHitRoll, modifier: action.hitBonus, total: Double(toHitTotal))

        // Roll damage
        let damageResult = rollDice(action.damageRoll)
        if damageResult.total > 0 {
            logRoll(type: "Action", name: "\(name) — \(action.name) (Damage)", roll: damageResult.rollSum, modifier: damageResult.modifier, total: Double(damageResult.total))
        }

        // Update entity actions
        switch entityType {
        case .player:
            guard let playerIndex = testPlayers.firstIndex(where: { $0.id == entityID }) else { return }
            guard let actionIndex = testPlayers[playerIndex].actions.firstIndex(where: { $0.id == action.id }) else { return }
            testPlayers[playerIndex].actions[actionIndex] = mutableAction
        case .npc:
            guard let npcIndex = testNPCs.firstIndex(where: { $0.id == entityID }) else { return }
            guard let actionIndex = testNPCs[npcIndex].actions.firstIndex(where: { $0.id == action.id }) else { return }
            testNPCs[npcIndex].actions[actionIndex] = mutableAction
        case .monster:
            break
        }
        publishNetworkSnapshot(reason: "action used")
    }

    func castSpell(_ spellEntry: SpellEntry, atLevel slotLevel: Int, forEntity entityID: UUID, entityType: InventoryEntityType, name: String) {
        // Expend slot
        if spellEntry.level > 0 {
            expendSpellSlot(level: slotLevel, for: entityID, entityType: entityType)
        }

        // Roll damage / healing if applicable
        if let damageRoll = spellEntry.damageRoll {
            let result = rollDice(damageRoll)
            let typeLabel = spellEntry.damageType.map { " \($0.rawValue)" } ?? ""
            logRoll(
                type: "Spell",
                name: "\(name) — \(spellEntry.name) (\(damageRoll)\(typeLabel))",
                roll: result.rollSum,
                modifier: result.modifier,
                total: Double(result.total)
            )
        } else {
            logRoll(
                type: "Spell",
                name: "\(name) — \(spellEntry.name)",
                roll: 0,
                modifier: 0,
                total: 0
            )
        }
        publishNetworkSnapshot(reason: "spell cast")
    }

    func longRest() {
        for index in combatents.indices {
            combatents[index].currentHP = combatents[index].maxHP
            combatents[index].temporaryHP = 0
            combatents[index].status = nil
            for slotIndex in combatents[index].spellSlots.indices {
                combatents[index].spellSlots[slotIndex].available = combatents[index].spellSlots[slotIndex].max
            }
        }
        for index in testPlayers.indices {
            testPlayers[index].currentHP = testPlayers[index].maxHP
            testPlayers[index].status = nil
            for slotIndex in testPlayers[index].spellSlots.indices {
                testPlayers[index].spellSlots[slotIndex].available = testPlayers[index].spellSlots[slotIndex].max
            }
            for actionIndex in testPlayers[index].actions.indices {
                if let maxUses = testPlayers[index].actions[actionIndex].maxUses {
                    testPlayers[index].actions[actionIndex].remainingUses = maxUses
                }
            }
        }
        for index in testNPCs.indices {
            testNPCs[index].currentHP = testNPCs[index].maxHP
            testNPCs[index].status = nil
            for slotIndex in testNPCs[index].spellSlots.indices {
                testNPCs[index].spellSlots[slotIndex].available = testNPCs[index].spellSlots[slotIndex].max
            }
            for actionIndex in testNPCs[index].actions.indices {
                if let maxUses = testNPCs[index].actions[actionIndex].maxUses {
                    testNPCs[index].actions[actionIndex].remainingUses = maxUses
                }
            }
        }
        publishNetworkSnapshot(reason: "long rest")
    }

    private func expendSpellSlot(level: Int, for entityID: UUID, entityType: InventoryEntityType) {
        // Update entity spell slots
        switch entityType {
        case .player:
            guard let playerIndex = testPlayers.firstIndex(where: { $0.id == entityID }) else { return }
            guard let slotIndex = testPlayers[playerIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            testPlayers[playerIndex].spellSlots[slotIndex].available -= 1
        case .npc:
            guard let npcIndex = testNPCs.firstIndex(where: { $0.id == entityID }) else { return }
            guard let slotIndex = testNPCs[npcIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            testNPCs[npcIndex].spellSlots[slotIndex].available -= 1
        case .monster:
            return // Monsters don't have stored spell slots
        }

        // Update combatent spell slots if present
        let sidebarID: String
        switch entityType {
        case .player:  sidebarID = "player-\(entityID.uuidString)"
        case .monster: sidebarID = "monster-\(entityID.uuidString)"
        case .npc:     sidebarID = "character-\(entityID.uuidString)"
        }
        if let combatentIndex = combatents.firstIndex(where: { $0.sourceSidebarID == sidebarID }) {
            guard let slotIndex = combatents[combatentIndex].spellSlots.firstIndex(where: { $0.level == level && $0.available > 0 }) else { return }
            combatents[combatentIndex].spellSlots[slotIndex].available -= 1
        }
    }
}
