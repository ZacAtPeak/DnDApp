import SwiftUI

struct SpellInventorySection: View {
    let knownSpellIDs: [String]
    let allSpells: [SpellEntry]
    let spellSlots: [SpellSlot]
    var onCast: ((SpellEntry, Int) -> Void)?

    private var knownSpells: [SpellEntry] {
        knownSpellIDs.compactMap { id in
            allSpells.first { $0.id == id }
        }
    }

    private var sortedSpells: [SpellEntry] {
        knownSpells.sorted { lhs, rhs in
            if lhs.level == rhs.level {
                return lhs.name < rhs.name
            }
            return lhs.level < rhs.level
        }
    }

    var body: some View {
        if !sortedSpells.isEmpty {
            DetailSection(title: "Spells") {
                VStack(spacing: 6) {
                    ForEach(sortedSpells) { spell in
                        SpellRow(spell: spell, spellSlots: spellSlots, onCast: onCast)
                    }
                }
            }
        }
    }
}

private struct SpellRow: View {
    let spell: SpellEntry
    let spellSlots: [SpellSlot]
    var onCast: ((SpellEntry, Int) -> Void)?

    @State private var isPresentingSlotPicker = false

    private var canCast: Bool {
        if spell.level == 0 { return true }
        let normalized = spellSlots.normalizedToLevel9()
        return normalized.contains { $0.level >= spell.level && $0.available > 0 }
    }

    private var levelText: String {
        spell.level == 0 ? "Cantrip" : "Level \(spell.level.romanNumeral)"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(spell.name)
                    .font(.system(size: 13, weight: .semibold))

                HStack(spacing: 4) {
                    Text(levelText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(spell.school)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            if let onCast {
                Button {
                    isPresentingSlotPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                        Text("Cast")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(canCast ? Color.accentColor : Color.secondary.opacity(0.2))
                    .foregroundStyle(canCast ? .white : .secondary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!canCast)
                .help(canCast ? "Cast \(spell.name)" : "No available spell slot of level \(spell.level) or higher")
                .popover(isPresented: $isPresentingSlotPicker, arrowEdge: .trailing) {
                    SpellSlotPickerPopover(
                        spell: spell,
                        spellSlots: spellSlots,
                        onSelect: { slotLevel in
                            onCast(spell, slotLevel)
                            isPresentingSlotPicker = false
                        }
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.secondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SpellSlotPickerPopover: View {
    let spell: SpellEntry
    let spellSlots: [SpellSlot]
    let onSelect: (Int) -> Void

    private var availableSlots: [SpellSlot] {
        spellSlots
            .normalizedToLevel9()
            .filter { $0.available > 0 && $0.level >= spell.level }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Cast \(spell.name)")
                    .font(.system(size: 15, weight: .bold))

                if spell.level > 0 {
                    Text("Select a spell slot of level \(spell.level.romanNumeral) or higher")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                } else {
                    Text("No spell slot required")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            if spell.level == 0 {
                Button {
                    onSelect(0)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkle")
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 20, height: 20)

                        Text("Cast Cantrip")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .background(Color.accentColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            } else if availableSlots.isEmpty {
                Text("No available spell slots")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 4) {
                    ForEach(availableSlots, id: \.level) { slot in
                        Button {
                            onSelect(slot.level)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: 20, height: 20)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Level \(slot.level.romanNumeral)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(.primary)

                                    Text("\(slot.available) of \(slot.max) remaining")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(16)
        .frame(minWidth: 220)
    }
}
