import SwiftUI

struct LootDetailView: View {
    let item: LootItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "backpack")
                    .font(.system(size: 32))
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 6) {
                        Text(item.type)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .font(.subheadline)
                            .foregroundStyle(.secondary.opacity(0.5))

                        Text(item.rarity)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(rarityColor)
                    }
                }
            }

            Divider()

            if item.requiresAttunement {
                Label("Requires Attunement", systemImage: "link")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }

            if let value = item.value {
                HStack(spacing: 4) {
                    Text("Value:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(item.description)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !item.properties.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Properties")
                        .font(.headline)
                        .fontWeight(.semibold)

                    ForEach(item.properties, id: \.self) { property in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.accentColor)
                            Text(property)
                                .font(.callout)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var rarityColor: Color {
        switch item.rarity.lowercased() {
        case "common": return .gray
        case "uncommon": return .green
        case "rare": return .blue
        case "very rare": return .purple
        case "legendary": return .orange
        case "artifact": return .red
        default: return .secondary
        }
    }
}
