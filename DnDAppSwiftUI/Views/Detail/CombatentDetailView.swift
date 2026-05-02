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

            if combatent.spellSlotCount > 0 {
                DetailSection(title: "Spell Slots") {
                    Text("\(combatent.spellSlotCount) remaining")
                        .foregroundStyle(.secondary)
                }
            }

            StatusesView(statuses: combatent.status ?? [])
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
