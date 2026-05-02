import SwiftUI

struct AbilityScoreCell: View {
    let label: String
    let value: Int
    let modifier: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.headline)

            Text(modifierText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var modifierText: String {
        modifier >= 0 ? "+\(modifier)" : "\(modifier)"
    }
}
