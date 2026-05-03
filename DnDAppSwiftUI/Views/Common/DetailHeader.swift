import SwiftUI

struct DetailHeader: View {
    let title: String
    let subtitle: String
    let hpText: String
    var isInTracker: Bool = false
    var onToggleTracker: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if let onToggleTracker {
                    Button(action: onToggleTracker) {
                        Image(systemName: isInTracker ? "xmark.circle.fill" : "plus.circle")
                            .foregroundStyle(isInTracker ? .red : .accentColor)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }

                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(hpText)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
