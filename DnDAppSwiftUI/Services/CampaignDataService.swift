import Foundation

enum CampaignDataServiceError: Error {
    case entityNotFound
}

final class CampaignDataService {
    static let shared = CampaignDataService()

    private init() {}

    // MARK: - Entity Lookup

    func player(for sidebarID: String?) -> PlayerCharacter? {
        entity(for: sidebarID, prefix: "player", in: testPlayers)
    }

    func monster(for sidebarID: String?) -> Monster? {
        entity(for: sidebarID, prefix: "monster", in: testMonsters)
    }

    func npc(for sidebarID: String?) -> NPC? {
        entity(for: sidebarID, prefix: "character", in: testNPCs)
    }

    func sidebarItem(withID id: String?, in items: [SidebarItem]) -> SidebarItem? {
        guard let id else { return nil }
        for item in items {
            if item.id == id { return item }
            if let childMatch = sidebarItem(withID: id, in: item.children ?? []) { return childMatch }
        }
        return nil
    }

    // MARK: - Combatent Factory

    func makeCombatent(from sidebarID: String) -> Combatent? {
        if let p = player(for: sidebarID) {
            return makeCombatent(from: p, sidebarID: sidebarID)
        }
        if let m = monster(for: sidebarID) {
            return makeCombatent(from: m, sidebarID: sidebarID)
        }
        if let n = npc(for: sidebarID) {
            return makeCombatent(from: n, sidebarID: sidebarID)
        }
        return nil
    }

    // MARK: - Initiative

    func rolledInitiative(for abilityScores: AbilityScores) -> Double {
        let roll = Int.random(in: 1...20)
        let initiativeBonus = Int(floor(Double(abilityScores.dexterity - 10) / 2))
        return Double(roll + initiativeBonus)
    }

    // MARK: - Helpers

    private func entity<T: CombatParticipant>(for sidebarID: String?, prefix: String, in collection: [T]) -> T? {
        guard let sidebarID, sidebarID.hasPrefix(prefix + "-") else { return nil }
        let rawID = String(sidebarID.dropFirst(prefix.count + 1))
        return collection.first { $0.id.uuidString == rawID }
    }

    private func makeCombatent(from player: PlayerCharacter, sidebarID: String) -> Combatent {
        Combatent(
            name: player.name,
            currentHP: player.currentHP,
            maxHP: player.maxHP,
            initiative: rolledInitiative(for: player.abilityScores),
            isTurn: false,
            status: player.status,
            creatureType: player.race,
            spellSlots: player.spellSlots.normalizedToLevel9(),
            speed: player.speed,
            sourceSidebarID: sidebarID
        )
    }

    private func makeCombatent(from monster: Monster, sidebarID: String) -> Combatent {
        Combatent(
            name: monster.name,
            currentHP: monster.currentHP,
            maxHP: monster.maxHP,
            initiative: rolledInitiative(for: monster.abilityScores),
            isTurn: false,
            status: monster.status,
            creatureType: monster.type.rawValue,
            spellSlots: monster.spellSlots.normalizedToLevel9(),
            speed: monster.speed,
            sourceSidebarID: sidebarID
        )
    }

    private func makeCombatent(from npc: NPC, sidebarID: String) -> Combatent {
        Combatent(
            name: npc.name,
            currentHP: npc.currentHP,
            maxHP: npc.maxHP,
            initiative: rolledInitiative(for: npc.abilityScores),
            isTurn: false,
            status: npc.status,
            creatureType: "Humanoid",
            spellSlots: npc.spellSlots.normalizedToLevel9(),
            speed: npc.speed,
            sourceSidebarID: sidebarID
        )
    }
}
