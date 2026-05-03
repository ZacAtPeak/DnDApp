import SwiftUI

struct InitiativeEditorView: View {
    @Binding var combatent: Combatent
    @Environment(\.dismiss) private var dismiss

    private var statuses: Binding<[StatusCondition]> {
        Binding {
            combatent.status ?? []
        } set: { updatedStatuses in
            combatent.status = updatedStatuses.isEmpty ? nil : updatedStatuses
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Combatant") {
                    TextField("Name", text: $combatent.name)

                    Toggle("Current Turn", isOn: $combatent.isTurn)

                    HStack {
                        Text("Initiative")
                        Spacer()
                        TextField("Initiative", value: $combatent.initiative, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 96)
                    }
                }

                Section("Hit Points") {
                    Stepper(value: $combatent.currentHP, in: 0...max(999, combatent.maxHP)) {
                        StatValueRow(title: "Current HP", value: combatent.currentHP)
                    }

                    Stepper(value: $combatent.maxHP, in: 1...999) {
                        StatValueRow(title: "Max HP", value: combatent.maxHP)
                    }
                }

                Section("Spell Slots") {
                    if combatent.spellSlots.isEmpty {
                        Text("No spell slots")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(combatent.spellSlots.indices, id: \.self) { index in
                            Stepper(value: $combatent.spellSlots[index].available, in: 0...combatent.spellSlots[index].max) {
                                StatValueRow(title: "Level \(combatent.spellSlots[index].level)", value: combatent.spellSlots[index].available)
                            }
                        }
                    }
                }

                Section("Statuses") {
                    let statusBindings = statuses

                    if statusBindings.wrappedValue.isEmpty {
                        Text("No active statuses")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(statusBindings.wrappedValue.indices, id: \.self) { index in
                            StatusEditorRow(statuses: statusBindings, index: index)
                        }
                    }

                    Button {
                        statusBindings.wrappedValue.append(
                            StatusCondition(name: "New Status", effect: "", desc: "")
                        )
                    } label: {
                        Label("Add Status", systemImage: "plus")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit Initiative")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 420, minHeight: 520)
        .onChange(of: combatent.maxHP) { _, newMaxHP in
            combatent.currentHP = min(combatent.currentHP, newMaxHP)
        }
    }
}
