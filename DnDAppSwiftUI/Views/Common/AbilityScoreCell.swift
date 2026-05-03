import SwiftUI

struct AbilityScoreCell: View {
    let label: String
    let value: Int
    let modifier: Int
    var isModified: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isModified {
                    Image(systemName: "sparkle")
                        .font(.system(size: 7))
                        .foregroundStyle(Color.accentColor)
                }
            }

            Text("\(value)")
                .font(.headline)
                .foregroundStyle(isModified ? Color.accentColor : Color.primary)

            Text(modifierText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isModified ? Color.accentColor.opacity(0.08) : Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(isModified ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private var modifierText: String {
        modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}
