import SwiftUI

struct PlayerCharacterDetailView: View {
    let player: PlayerCharacter
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? player.status ?? []
    }

    private var currentHP: Int {
        encounterCombatent?.currentHP ?? player.currentHP
    }

    private var maxHP: Int {
        encounterCombatent?.maxHP ?? player.maxHP
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.title2)
                    .fontWeight(.bold)

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
                hitDice: player.hitDice,
                initiative: encounterCombatent?.initiative ?? player.initiative,
                speed: player.speed,
                senses: player.senses,
                languages: []
            )

            StatusesView(statuses: activeStatuses)
            SpellSlotsView(slots: encounterCombatent?.spellSlots ?? player.spellSlots)
            AbilityScoresView(scores: player.abilityScores)
            SpecialAbilitiesView(abilities: player.specialAbilities)
            ActionsView(actions: player.actions)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
