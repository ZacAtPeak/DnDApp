import SwiftUI

struct SpellDetailView: View {
    let spell: SpellEntry

    private var levelLabel: String {
        spell.level == 0 ? "Cantrip" : "\(spell.level.romanNumeral) Level"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(spell.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 6) {
                    Text(levelLabel)
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text(spell.school)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    if spell.ritual {
                        Text("(ritual)")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                if spell.concentration {
                    Label("Concentration", systemImage: "brain")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                SpellStatRow(label: "Casting Time", value: spell.castingTime)
                SpellStatRow(label: "Range", value: spell.range)
                SpellStatRow(label: "Components", value: spell.components)
                SpellStatRow(label: "Duration", value: spell.duration)
                if let dc = spell.saveDC {
                    SpellStatRow(label: "Save DC", value: "\(dc)")
                }
            }

            Divider()

            Text(spell.description)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct SpellStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
        }
    }
}
