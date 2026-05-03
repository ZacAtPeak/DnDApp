import SwiftUI

struct WikiEntryCreationView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (WikiEntry) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var aliases: [String] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry") {
                    TextField("Title", text: $title)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Aliases") {
                    ForEach(aliases.indices, id: \.self) { index in
                        TextField("e.g. Spell Slot", text: $aliases[index])
                    }
                    .onDelete { indices in
                        aliases.remove(atOffsets: indices)
                    }

                    Button {
                        aliases.append("")
                    } label: {
                        Label("Add Alias", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Wiki Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = WikiEntry(
                            id: slugify(title),
                            title: title,
                            description: description,
                            aliases: aliases
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 420)
    }

    private func slugify(_ text: String) -> String {
        let slug = text
            .lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        return slug.isEmpty ? "entry" : slug
    }
}
