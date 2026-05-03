import SwiftUI

struct InventorySection: View {
    let inventory: [InventoryItem]
    let allLoot: [LootItem]
    var onToggleEquip: ((UUID) -> Void)?

    var body: some View {
        if !inventory.isEmpty {
            DetailSection(title: "Inventory") {
                VStack(spacing: 6) {
                    ForEach(inventory) { invItem in
                        if let lootItem = allLoot.first(where: { $0.id == invItem.lootItemID }) {
                            InventoryRow(invItem: invItem, lootItem: lootItem, onToggleEquip: onToggleEquip)
                        }
                    }
                }
            }
        }
    }
}

private struct InventoryRow: View {
    let invItem: InventoryItem
    let lootItem: LootItem
    var onToggleEquip: ((UUID) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(lootItem.name)
                        .font(.system(size: 13, weight: .semibold))

                    if invItem.isEquipped {
                        Text("Equipped")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 4) {
                    Text(lootItem.type)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(lootItem.rarity)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(rarityColor(lootItem.rarity))
                }

                if invItem.isEquipped, !lootItem.modifiers.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(lootItem.modifiers, id: \.self) { modifier in
                            Label(modifier.displayText, systemImage: "sparkle")
                                .font(.system(size: 11))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: 8)

            if let onToggleEquip {
                Button {
                    onToggleEquip(invItem.id)
                } label: {
                    Image(systemName: invItem.isEquipped ? "checkmark.shield.fill" : "shield")
                        .font(.system(size: 16))
                        .foregroundStyle(invItem.isEquipped ? Color.accentColor : Color.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
                .help(invItem.isEquipped ? "Unequip" : "Equip")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(invItem.isEquipped ? Color.accentColor.opacity(0.07) : Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private func rarityColor(_ rarity: String) -> Color {
    switch rarity.lowercased() {
    case "common":    return .gray
    case "uncommon":  return .green
    case "rare":      return .blue
    case "very rare": return .purple
    case "legendary": return .orange
    case "artifact":  return .red
    default:          return .secondary
    }
}
