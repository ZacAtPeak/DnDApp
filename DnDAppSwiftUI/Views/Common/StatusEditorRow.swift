import SwiftUI

struct StatusEditorRow: View {
    @Binding var statuses: [StatusCondition]
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                TextField("Name", text: binding(for: \.name))
                    .fontWeight(.semibold)

                Spacer()

                Button(role: .destructive) {
                    statuses.remove(at: index)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.borderless)
                .help("Remove status")
            }

            TextField("Effect", text: binding(for: \.effect))

            TextField("Description", text: binding(for: \.desc), axis: .vertical)
                .lineLimit(2...4)
        }
        .padding(.vertical, 6)
    }

    private func binding(for keyPath: WritableKeyPath<StatusCondition, String>) -> Binding<String> {
        Binding {
            guard statuses.indices.contains(index) else { return "" }
            return statuses[index][keyPath: keyPath]
        } set: { updatedValue in
            guard statuses.indices.contains(index) else { return }
            statuses[index][keyPath: keyPath] = updatedValue
        }
    }
}
