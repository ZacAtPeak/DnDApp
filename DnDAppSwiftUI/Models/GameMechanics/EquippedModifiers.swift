import Foundation

struct EquippedModifiers {
    var acBonus: Int = 0
    var savingThrowBonus: Int = 0
    var attackBonus: Int = 0
    var damageBonus: Int = 0
    var abilityScoreOverrides: [String: Int] = [:]

    var isEmpty: Bool {
        acBonus == 0 && savingThrowBonus == 0 && attackBonus == 0 && damageBonus == 0 && abilityScoreOverrides.isEmpty
    }

    var modifiedAbilityKeys: Set<String> { Set(abilityScoreOverrides.keys) }

    func effectiveScores(base: AbilityScores) -> AbilityScores {
        var s = base
        if let v = abilityScoreOverrides["STR"] { s.strength = v }
        if let v = abilityScoreOverrides["DEX"] { s.dexterity = v }
        if let v = abilityScoreOverrides["CON"] { s.constitution = v }
        if let v = abilityScoreOverrides["INT"] { s.intelligence = v }
        if let v = abilityScoreOverrides["WIS"] { s.wisdom = v }
        if let v = abilityScoreOverrides["CHA"] { s.charisma = v }
        return s
    }

    func effectiveAC(base: Int) -> Int { base + acBonus }
}

extension Array where Element == LootItem {
    func equippedModifiers(for inventory: [InventoryItem]) -> EquippedModifiers {
        var result = EquippedModifiers()
        for invItem in inventory where invItem.isEquipped {
            guard let lootItem = first(where: { $0.id == invItem.lootItemID }) else { continue }
            for modifier in lootItem.modifiers {
                switch modifier {
                case .acBonus(let v):              result.acBonus += v
                case .savingThrowBonus(let v):     result.savingThrowBonus += v
                case .attackBonus(let v):          result.attackBonus += v
                case .damageBonus(let v):          result.damageBonus += v
                case .setAbilityScore(let a, let v): result.abilityScoreOverrides[a] = v
                }
            }
        }
        return result
    }
}
