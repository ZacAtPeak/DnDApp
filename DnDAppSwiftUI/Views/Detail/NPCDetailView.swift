import SwiftUI

struct NPCDetailView: View {
    let npc: NPC
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
        encounterCombatent?.status ?? npc.status ?? []
    }

    private var equippedMods: EquippedModifiers {
        allLoot.equippedModifiers(for: inventory)
    }

    private var effectiveScores: AbilityScores {
        equippedMods.effectiveScores(base: npc.abilityScores)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: npc.name,
                subtitle: "\(npc.role) - \(npc.size.rawValue), \(npc.alignment.rawValue)",
                hpText: "HP \(encounterCombatent?.currentHP ?? npc.currentHP)/\(encounterCombatent?.maxHP ?? npc.maxHP)",
                isInTracker: isInTracker,
                onToggleTracker: onToggleTracker
            )

            WikiLinkedText(text: npc.biography)
                .foregroundStyle(.secondary)

            CreatureSummaryGrid(
                armorClass: npc.armorClass,
                armorSource: npc.armorSource,
                acBonus: equippedMods.acBonus,
                hitDice: npc.hitDice,
                initiative: encounterCombatent?.initiative ?? npc.initiative,
                speed: npc.speed,
                senses: npc.senses,
                languages: npc.languages
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: encounterCombatent?.spellSlots ?? npc.spellSlots)
            SpellInventorySection(
                knownSpellIDs: npc.knownSpells,
                allSpells: allSpells,
                spellSlots: encounterCombatent?.spellSlots ?? npc.spellSlots,
                onCast: onCastSpell
            )
            AbilityScoresView(
                scores: effectiveScores,
                modifiedAbilities: equippedMods.modifiedAbilityKeys,
                onRoll: onRollAbility
            )
            SkillsView(skills: npc.skills, onRoll: onRollSkill)
            SpecialAbilitiesView(abilities: npc.specialAbilities)
            ActionsView(actions: npc.actions, onUseAction: onUseAction)
            InventorySection(inventory: inventory, allLoot: allLoot, onToggleEquip: onToggleEquip)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
