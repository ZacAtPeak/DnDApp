import SwiftUI

struct MonsterDetailView: View {
    let monster: Monster
    let encounterCombatent: Combatent?

    private var activeStatuses: [StatusCondition] {
        encounterCombatent?.status ?? monster.status ?? []
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
            AbilityScoresView(scores: monster.abilityScores)
            SpecialAbilitiesView(abilities: monster.specialAbilities)
            ActionsView(actions: monster.actions)

            if let legendaryActions = monster.legendaryActions, !legendaryActions.isEmpty {
                LegendaryActionsView(actions: legendaryActions, count: monster.legendaryActionCount)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
