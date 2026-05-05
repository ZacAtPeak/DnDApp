import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: CampaignViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showRemoveConfirmation = false
    @State private var showRestoreConfirmation = false

    @State private var hostSessionName = ""
    @State private var clientHPInput = ""
    @State private var clientTempHPInput = ""

    var body: some View {
        NavigationStack {
            Form {
                networkingSection
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

// MARK: - Networking Section

extension SettingsView {
    @ViewBuilder
    private var networkingSection: some View {
        let net = viewModel.networkingService

        Section("Networking") {
            // Status
            HStack {
                Text("Status")
                Spacer()
                Text(connectionStateLabel(net.connectionState))
                    .foregroundStyle(.secondary)
            }

            if let role = net.role {
                HStack {
                    Text("Role")
                    Spacer()
                    Text(role == .host ? "Host (DM)" : "Client (Player)")
                        .foregroundStyle(.secondary)
                }
            }

            if let error = net.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // Host controls
            if net.role == nil || net.role == .host {
                if case .hosting = net.connectionState {
                    Button("Stop Hosting") { viewModel.stopNetworking() }
                } else if net.role == nil {
                    HStack {
                        TextField("Session Name", text: $hostSessionName)
                            .textFieldStyle(.roundedBorder)
                        Button("Host") {
                            let name = hostSessionName.isEmpty ? "\(ProcessInfo.processInfo.hostName)'s Session" : hostSessionName
                            viewModel.startHostingCampaignSession(name: name)
                        }
                    }
                }
            }

            // Client controls
            if net.role == nil || net.role == .client {
                if case .browsing = net.connectionState {
                    Button("Stop Browsing") { viewModel.stopNetworking() }
                } else if net.connectionState.peerName != nil {
                    Button("Disconnect") { viewModel.stopNetworking() }
                } else if net.role == nil {
                    Button("Browse for Sessions") { viewModel.startBrowsingCampaignSessions() }
                }
            }
        }

        // Discovered peers (client browsing)
        if net.role == .client, case .browsing = net.connectionState, !net.discoveredPeers.isEmpty {
            Section("Discovered Sessions") {
                ForEach(net.discoveredPeers) { peer in
                    Button {
                        viewModel.connectToCampaignSession(peer)
                    } label: {
                        Label(peer.name, systemImage: "network")
                    }
                }
            }
        }

        // Connected clients (host)
        if net.role == .host, !net.connectedClients.isEmpty {
            Section("Connected Clients") {
                ForEach(Array(net.connectedClients.values).sorted(by: { $0.displayName < $1.displayName })) { client in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.displayName)
                            .font(.body)
                        if let assignedID = client.assignedPlayerID,
                           let player = testPlayers.first(where: { $0.id == assignedID }) {
                            Text("Assigned: \(player.name)")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            // Assignment picker
                            Picker("Assign Player", selection: Binding(
                                get: { client.assignedPlayerID },
                                set: { newID in
                                    if let id = newID {
                                        viewModel.assignPlayerCharacter(id, to: client.id)
                                    } else {
                                        viewModel.unassignPlayerCharacter(from: client.id)
                                    }
                                }
                            )) {
                                Text("None").tag(UUID?.none)
                                ForEach(testPlayers, id: \.id) { player in
                                    Text(player.name).tag(Optional(player.id))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
            }
        }

        // Client assignment info + test controls
        if net.role == .client, net.connectionState.peerName != nil {
            Section("Your Assignment") {
                if let assignment = viewModel.networkAssignments.first,
                   let player = testPlayers.first(where: { $0.id == assignment.playerCharacterID }) {
                    Text("Playing as: \(player.name)")
                        .font(.headline)
                    Text("HP: \(player.currentHP)/\(player.maxHP)")
                        .font(.subheadline)

                    // Test HP update
                    HStack {
                        TextField("HP", text: $clientHPInput)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        TextField("Temp HP", text: $clientTempHPInput)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Button("Set HP") {
                            let hp = Int(clientHPInput) ?? player.currentHP
                            let thp = Int(clientTempHPInput) ?? 0
                            viewModel.sendAssignedPlayerUpdate(
                                .setHitPoints(playerID: player.id, currentHP: hp, temporaryHP: thp))
                        }
                    }

                    // Test roll submission
                    Button("Submit Test Roll (d20)") {
                        let roll = Int.random(in: 1...20)
                        let entry = NetworkRollEntry(
                            from: RollEntry(type: "Test", name: "\(player.name) — d20",
                                            roll: roll, modifier: 0, total: Double(roll), timestamp: Date()))
                        viewModel.sendAssignedPlayerUpdate(
                            .submitRoll(playerID: player.id, roll: entry))
                    }
                } else {
                    Text("No player assigned yet. Wait for the DM to assign you.")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func connectionStateLabel(_ state: CampaignConnectionState) -> String {
        switch state {
        case .idle: return "Idle"
        case .browsing: return "Browsing..."
        case .hosting(let port): return port.map { "Hosting (port \($0))" } ?? "Starting host..."
        case .connecting: return "Connecting..."
        case .connectedUnsynced(let name): return "Connected to \(name) (unsynced)"
        case .syncing(let name): return "Syncing with \(name)..."
        case .ready(let name): return "Connected to \(name)"
        case .stale(let name): return "Stale sync with \(name)"
        case .failed(let msg): return "Failed: \(msg)"
        }
    }
}

#Preview {
    SettingsView(viewModel: CampaignViewModel(dataService: CampaignDataService.shared))
}
