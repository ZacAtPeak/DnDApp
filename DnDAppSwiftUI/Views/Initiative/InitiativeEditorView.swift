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
                    Stepper(value: $combatent.spellSlotCount, in: 0...99) {
                        StatValueRow(title: "Remaining Slots", value: combatent.spellSlotCount)
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
