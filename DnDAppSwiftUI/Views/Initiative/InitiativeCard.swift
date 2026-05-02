import SwiftUI

struct InitiativeCard: View {
    var combatent: Combatent
    var isSelected: Bool
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onStatusDrop: ([String]) -> Bool
    @State private var isStatusTargeted = false

    private var activeStatuses: [StatusCondition] {
        combatent.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(combatent.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    if let creatureType = combatent.creatureType {
                        Text(creatureType)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(combatent.initiative))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            Text("HP: \(combatent.currentHP)/\(combatent.maxHP)")
                .font(.subheadline)

            if combatent.spellSlotCount > 0 {
                Text("Spell slots: \(combatent.spellSlotCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !activeStatuses.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Statuses")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(activeStatuses, id: \.name) { status in
                        Text(status.name)
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .frame(width: 180, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: isSelected || combatent.isTurn ? 2 : 1)
        }
        .overlay {
            if isStatusTargeted {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture(perform: onSelect)
        .onLongPressGesture(perform: onEdit)
        .dropDestination(for: String.self) { payloads, _ in
            onStatusDrop(payloads)
        } isTargeted: { targeted in
            isStatusTargeted = targeted
        }
        .contextMenu {
            Button("Edit") {
                onEdit()
            }
        }
        .help("Long press or secondary-click to edit")
    }

    private var cardStrokeColor: Color {
        if isSelected {
            return .accentColor
        }
        return combatent.isTurn ? .orange : Color.secondary.opacity(0.2)
    }
}
