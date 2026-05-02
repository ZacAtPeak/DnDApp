import SwiftUI

struct NPCDetailView: View {
    let npc: NPC
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? npc.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: npc.name,
                subtitle: "\(npc.role) - \(npc.size.rawValue), \(npc.alignment.rawValue)",
                hpText: "HP \(encounterCombatent?.currentHP ?? npc.currentHP)/\(encounterCombatent?.maxHP ?? npc.maxHP)"
            )

            Text(npc.biography)
                .foregroundStyle(.secondary)

            CreatureSummaryGrid(
                armorClass: npc.armorClass,
                armorSource: npc.armorSource,
                hitDice: npc.hitDice,
                initiative: encounterCombatent?.initiative ?? npc.initiative,
                speed: npc.speed,
                senses: npc.senses,
                languages: npc.languages
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: npc.spellSlots, encounterSlotCount: encounterCombatent?.spellSlotCount)
            AbilityScoresView(scores: npc.abilityScores)
            SpecialAbilitiesView(abilities: npc.specialAbilities)
            ActionsView(actions: npc.actions)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
