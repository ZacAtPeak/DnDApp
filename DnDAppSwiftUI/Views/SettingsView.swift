import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: CampaignViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showRemoveConfirmation = false
    @State private var showRestoreConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Data Management") {
                    Button(role: .destructive) {
                        showRemoveConfirmation = true
                    } label: {
                        Label("Remove Demo Data", systemImage: "trash")
                    }

                    Button {
                        showRestoreConfirmation = true
                    } label: {
                        Label("Restore Demo Data", systemImage: "arrow.counterclockwise")
                    }
                }

                Section("Saved Sessions") {
                    if viewModel.savedSessionFileInfos.isEmpty {
                        Text("No saved sessions yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.savedSessionFileInfos) { info in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(info.displayName)
                                        .font(.body)
                                    Text(info.creationDate, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                ShareLink(item: info.url) {
                                    Image(systemName: "square.and.arrow.up")
                                        .imageScale(.large)
                                }
                                .accessibilityLabel("Share session file")
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteSavedSession(at: viewModel.savedSessionFileInfos[index].url)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Remove all demo data?",
                isPresented: $showRemoveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove All Data", role: .destructive) {
                    viewModel.removeDemoData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all players, monsters, NPCs, encounters, wiki entries, loot, spells, assets, and roll history.")
            }
            .confirmationDialog(
                "Restore demo data?",
                isPresented: $showRestoreConfirmation,
                titleVisibility: .visible
            ) {
                Button("Restore Demo Data") {
                    viewModel.restoreDemoData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all data to the original demo state.")
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView(viewModel: CampaignViewModel(dataService: CampaignDataService.shared))
}
