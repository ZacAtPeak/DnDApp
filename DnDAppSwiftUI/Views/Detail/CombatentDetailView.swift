import SwiftUI

struct CombatentDetailView: View {
    let combatent: Combatent

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DetailHeader(
                title: combatent.name,
                subtitle: "Initiative \(Int(combatent.initiative))",
                hpText: "HP \(combatent.currentHP)/\(combatent.maxHP)"
            )

            SpellSlotsView(slots: combatent.spellSlots)

            StatusesView(statuses: combatent.status ?? [])
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
