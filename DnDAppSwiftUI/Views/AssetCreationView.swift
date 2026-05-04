import SwiftUI

struct AssetCreationView: View {
    @Environment(\.dismiss) private var dismiss
    let isPublic: Bool
    var onSave: (Asset) -> Void

    @State private var name = ""
    @State private var type: AssetType = .location
    @State private var description = ""
    @State private var location = ""
    @State private var difficulty = ""
    @State private var rewards = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Asset Name") {
                    TextField("e.g. The Sunken Temple", text: $name)
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(AssetType.allCases, id: \.self) { assetType in
                            Text(assetType.rawValue).tag(assetType)
                        }
                    }
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Details") {
                    TextField("Location", text: $location)
                    TextField("Difficulty", text: $difficulty)
                    TextField("Rewards", text: $rewards)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isPublic ? "New Public Asset" : "New Private Asset")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let asset = Asset(
                            id: slugify(name),
                            name: name,
                            type: type,
                            description: description,
                            isPublic: isPublic,
                            location: location.isEmpty ? nil : location,
                            difficulty: difficulty.isEmpty ? nil : difficulty,
                            rewards: rewards.isEmpty ? nil : rewards
                        )
                        onSave(asset)
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
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
        return slug.isEmpty ? "asset" : slug
    }
}
