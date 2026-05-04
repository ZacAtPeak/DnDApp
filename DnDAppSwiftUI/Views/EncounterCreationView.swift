import SwiftUI

struct EncounterCreationView: View {
    var onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @FocusState private var nameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Encounter") {
                    TextField("Name", text: $name)
                        .focused($nameFocused)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Encounter")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onSave(trimmedName)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
        .frame(minWidth: 360, minHeight: 200)
    }
}
