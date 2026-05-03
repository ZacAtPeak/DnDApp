import SwiftUI

struct InitiativeCard: View {
    var combatent: Combatent
    var isSelected: Bool
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onRemove: () -> Void
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

            if !combatent.isLairAction {
                Text("HP: \(combatent.currentHP)/\(combatent.maxHP)")
                    .font(.subheadline)
            }

            if !combatent.spellSlots.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(combatent.spellSlots, id: \.level) { slot in
                        if slot.available > 0 {
                            HStack(spacing: 2) {
                                ForEach(0..<slot.available, id: \.self) { _ in
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 7))
                                }
                            }
                        }
                    }
                }
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
        .frame(width: 160, alignment: .leading)
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
            Button("Remove from Initiative", role: .destructive) {
                onRemove()
            }
        }
        .help("Long press or secondary-click to edit")
    }

    private var cardStrokeColor: Color {
        if isSelected {
            return .accentColor
        }
        if combatent.isLairAction {
            return .purple.opacity(0.6)
        }
        return combatent.isTurn ? .orange : Color.secondary.opacity(0.2)
    }
}
