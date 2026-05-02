import SwiftUI

struct StatusPaletteView: View {
    let statuses: [StatusCondition]
    var onSelect: (StatusCondition) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(statuses, id: \.name) { status in
                    Button {
                        onSelect(status)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(status.name)
                                .font(.headline)

                            Text(status.effect)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .draggable(statusDragPayload(for: status))
                    .help("Click to queue, or drag onto an initiative card")
                }
            }
            .padding()
        }
        .frame(width: 260, height: 360)
    }
}
