import SwiftUI

struct StatusesView: View {
    let statuses: [StatusCondition]

    var body: some View {
        DetailSection(title: "Statuses") {
            if statuses.isEmpty {
                Text("No active statuses")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(statuses, id: \.name) { status in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(status.name)
                            .font(.headline)

                        Text(status.effect)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(status.desc)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}
