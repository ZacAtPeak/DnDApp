import SwiftUI

struct MonsterDetailView: View {
    let monster: Monster
    let encounterCombatent: Combatent?
    var inventory: [InventoryItem] = []
    var allLoot: [LootItem] = []
    var allSpells: [SpellEntry] = spellDemoData
    var onToggleEquip: ((UUID) -> Void)?
    var onRollAbility: ((String, Int) -> Void)?
    var onRollSkill: ((String, Int) -> Void)?
    var onCastSpell: ((SpellEntry, Int) -> Void)?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? monster.status ?? []
    }

    private var equippedMods: EquippedModifiers {
        allLoot.equippedModifiers(for: inventory)
    }

    private var effectiveScores: AbilityScores {
        equippedMods.effectiveScores(base: monster.abilityScores)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: monster.name,
                subtitle: "\(monster.size.rawValue) \(monster.type.rawValue), \(monster.alignment.rawValue)",
                hpText: "HP \(encounterCombatent?.currentHP ?? monster.currentHP)/\(encounterCombatent?.maxHP ?? monster.maxHP)"
            )

            CreatureSummaryGrid(
                armorClass: monster.armorClass,
                armorSource: monster.armorSource,
                acBonus: equippedMods.acBonus,
                hitDice: monster.hitDice,
                initiative: encounterCombatent?.initiative ?? monster.initiative,
                speed: monster.speed,
                senses: monster.senses,
                languages: monster.languages
            )

            DetailSection(title: "Challenge") {
                HStack {
                    Text("CR \(monster.challengeRating, specifier: "%g")")
                    Spacer()
                    Text("\(monster.xp) XP")
                        .foregroundStyle(.secondary)
                }
            }

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: encounterCombatent?.spellSlots ?? monster.spellSlots)
            SpellInventorySection(
                knownSpellIDs: monster.knownSpells,
                allSpells: allSpells,
                spellSlots: encounterCombatent?.spellSlots ?? monster.spellSlots,
                onCast: onCastSpell
            )
            AbilityScoresView(
                scores: effectiveScores,
                modifiedAbilities: equippedMods.modifiedAbilityKeys,
                onRoll: onRollAbility
            )
            SkillsView(skills: monster.skills, onRoll: onRollSkill)
            SpecialAbilitiesView(abilities: monster.specialAbilities)
            ActionsView(actions: monster.actions)

            if let legendaryActions = monster.legendaryActions, !legendaryActions.isEmpty {
                LegendaryActionsView(actions: legendaryActions, count: monster.legendaryActionCount)
            }

            InventorySection(inventory: inventory, allLoot: allLoot, onToggleEquip: onToggleEquip)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
