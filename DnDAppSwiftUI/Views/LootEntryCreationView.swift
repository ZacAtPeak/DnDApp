import SwiftUI

struct LootEntryCreationView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (LootItem) -> Void

    @State private var name = ""
    @State private var type = ""
    @State private var rarity = "Common"
    @State private var customRarity = ""
    @State private var description = ""
    @State private var value = ""
    @State private var requiresAttunement = false
    @State private var properties: [String] = []
    @State private var modifiers: [ModifierForm] = []

    private let rarityOptions = ["Common", "Uncommon", "Rare", "Very Rare", "Legendary", "Artifact", "Other"]
    private let abilityOptions = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]

    struct ModifierForm: Identifiable {
        let id = UUID()
        var kind: Kind
        var value: Int
        var ability: String

        enum Kind: String, CaseIterable {
            case acBonus = "AC Bonus"
            case savingThrowBonus = "Saving Throw Bonus"
            case attackBonus = "Atk Bonus"
            case damageBonus = "Dmg Bonus"
            case setAbilityScore = "Set Ability Score"
        }

        var itemModifier: ItemModifier {
            switch kind {
            case .acBonus:              return .acBonus(value)
            case .savingThrowBonus:     return .savingThrowBonus(value)
            case .attackBonus:          return .attackBonus(value)
            case .damageBonus:          return .damageBonus(value)
            case .setAbilityScore:      return .setAbilityScore(ability, value)
            }
        }
    }

    private var finalRarity: String {
        rarity == "Other" ? customRarity : rarity
    }

    private var isValid: Bool {
        !name.isEmpty && !type.isEmpty && !finalRarity.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Name", text: $name)
                    TextField("Type (e.g. Weapon, Armor, Wondrous Item)", text: $type)
                    Picker("Rarity", selection: $rarity) {
                        ForEach(rarityOptions, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }
                    .pickerStyle(.menu)
                    if rarity == "Other" {
                        TextField("Custom Rarity", text: $customRarity)
                    }
                    TextField("Value (e.g. 5,000 gp)", text: $value)
                }

                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section("Attunement") {
                    Toggle("Requires Attunement", isOn: $requiresAttunement)
                }

                Section("Properties") {
                    if properties.isEmpty {
                        Text("No properties")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(properties.indices, id: \.self) { index in
                            TextField("Property", text: $properties[index])
                        }
                        .onDelete { indices in
                            properties.remove(atOffsets: indices)
                        }
                    }
                    Button {
                        properties.append("")
                    } label: {
                        Label("Add Property", systemImage: "plus")
                    }
                }

                Section("Modifiers") {
                    if modifiers.isEmpty {
                        Text("No modifiers")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach($modifiers) { $modifier in
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Kind", selection: $modifier.kind) {
                                    ForEach(ModifierForm.Kind.allCases, id: \.self) { k in
                                        Text(k.rawValue).tag(k)
                                    }
                                }
                                .pickerStyle(.segmented)

                                if modifier.kind == .setAbilityScore {
                                    Picker("Ability", selection: $modifier.ability) {
                                        ForEach(abilityOptions, id: \.self) { a in
                                            Text(a).tag(a)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                Stepper(value: $modifier.value, in: -10...30) {
                                    LabeledContent("Value", value: "\(modifier.value)")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indices in
                            modifiers.remove(atOffsets: indices)
                        }
                    }
                    Button {
                        modifiers.append(ModifierForm(kind: .acBonus, value: 1, ability: "STR"))
                    } label: {
                        Label("Add Modifier", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Loot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = LootItem(
                            id: slugify(name),
                            name: name,
                            type: type,
                            rarity: finalRarity,
                            description: description,
                            value: value.isEmpty ? nil : value,
                            requiresAttunement: requiresAttunement,
                            properties: properties
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty },
                            modifiers: modifiers.map(\.itemModifier)
                        )
                        onSave(item)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 600)
    }

    private func slugify(_ text: String) -> String {
        let slug = text
            .lowercased()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        return slug.isEmpty ? "loot" : slug
    }
}

#Preview {
    LootEntryCreationView { _ in }
}

