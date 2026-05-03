import SwiftUI

struct PlayerCharacterDetailView: View {
    let player: PlayerCharacter
    let encounterCombatent: Combatent?
    var inventory: [InventoryItem] = []
    var allLoot: [LootItem] = []
    var allSpells: [SpellEntry] = spellDemoData
    var onToggleEquip: ((UUID) -> Void)?
    var onRollAbility: ((String, Int) -> Void)?
    var onRollSkill: ((String, Int) -> Void)?
    var onCastSpell: ((SpellEntry, Int) -> Void)?
    var onUseAction: ((Attack) -> Void)?
    var isInTracker: Bool = false
    var onToggleTracker: (() -> Void)? = nil

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? player.status ?? []
    }

    private var currentHP: Int {
        encounterCombatent?.currentHP ?? player.currentHP
    }

    private var maxHP: Int {
        encounterCombatent?.maxHP ?? player.maxHP
    }

    private var equippedMods: EquippedModifiers {
        allLoot.equippedModifiers(for: inventory)
    }

    private var effectiveScores: AbilityScores {
        equippedMods.effectiveScores(base: player.abilityScores)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if let onToggleTracker {
                        Button(action: onToggleTracker) {
                            Image(systemName: isInTracker ? "xmark.circle.fill" : "plus.circle")
                                .foregroundStyle(isInTracker ? .red : .accentColor)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }

                    Text(player.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Text("\(player.race) \(player.playerClass) \(player.level)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("HP \(currentHP)/\(maxHP)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            CreatureSummaryGrid(
                armorClass: player.armorClass,
                armorSource: player.armorSource,
                acBonus: equippedMods.acBonus,
                hitDice: player.hitDice,
                initiative: encounterCombatent?.initiative ?? player.initiative,
                speed: player.speed,
                senses: player.senses,
                languages: []
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: encounterCombatent?.spellSlots ?? player.spellSlots)
            SpellInventorySection(
                knownSpellIDs: player.knownSpells,
                allSpells: allSpells,
                spellSlots: encounterCombatent?.spellSlots ?? player.spellSlots,
                onCast: onCastSpell
            )
            AbilityScoresView(
                scores: effectiveScores,
                modifiedAbilities: equippedMods.modifiedAbilityKeys,
                onRoll: onRollAbility
            )
            SkillsView(skills: player.skills, onRoll: onRollSkill)
            SpecialAbilitiesView(abilities: player.specialAbilities)
            ActionsView(actions: player.actions, onUseAction: onUseAction)
            InventorySection(inventory: inventory, allLoot: allLoot, onToggleEquip: onToggleEquip)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
