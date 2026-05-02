//
//  ContentView.swift
//  DnDAppSwiftUI
//
//  Created by Zachary Reyes on 5/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedItemID: String? = "players"
    @State private var combatents: [Combatent] = []
    @State private var isInitiativeTargeted = false

    var body: some View {
        NavigationSplitView {
            List(sidebarItems, children: \.children, selection: $selectedItemID) { item in
                Label(item.title, systemImage: item.systemImage)
                    .draggable(item.id)
            }
            .navigationTitle("Navigation")
        } detail: {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Initiative Tracker")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                            .padding(.top)

                        ScrollView(.horizontal) {
                            HStack(alignment: .top, spacing: 16) {
                                if combatents.isEmpty {
                                    Text("Drag characters here to add them to initiative")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .frame(minWidth: 300)
                                        .padding(.vertical, 8)
                                } else {
                                    ForEach(combatents) { combatent in
                                        InitiativeCard(combatent: combatent)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                    .background(.bar)
                    .overlay {
                        if isInitiativeTargeted {
                            Rectangle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .allowsHitTesting(false)
                        }
                    }
                    .dropDestination(for: String.self) { ids, _ in
                        let added = ids.compactMap { makeCombatent(from: $0) }
                        combatents.append(contentsOf: added)
                        return !added.isEmpty
                    } isTargeted: { targeted in
                        isInitiativeTargeted = targeted
                    }

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            if let selectedPlayer {
                                PlayerCharacterDetailView(player: selectedPlayer)
                            } else if let selectedItem = selectedSidebarItem {
                                Text(selectedItem.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text("Detail view content goes here.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                .toolbar {
                    ToolbarItem() {
                        Menu {
                            Button("Character") {}
                            Button("Private Asset") {}
                            Button("Public Asset") {}
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }

    private var selectedSidebarItem: SidebarItem? {
        findSidebarItem(withID: selectedItemID, in: sidebarItems)
    }

    private var selectedPlayer: PlayerCharacter? {
        guard
            let selectedItemID,
            selectedItemID.hasPrefix("player-")
        else {
            return nil
        }

        let playerID = String(selectedItemID.dropFirst("player-".count))
        return testPlayers.first { $0.id.uuidString == playerID }
    }

    private func findSidebarItem(withID id: String?, in items: [SidebarItem]) -> SidebarItem? {
        guard let id else { return nil }

        for item in items {
            if item.id == id { return item }
            if let childMatch = findSidebarItem(withID: id, in: item.children ?? []) { return childMatch }
        }

        return nil
    }

    private func makeCombatent(from sidebarID: String) -> Combatent? {
        if sidebarID.hasPrefix("player-") {
            let rawID = String(sidebarID.dropFirst("player-".count))
            guard let player = testPlayers.first(where: { $0.id.uuidString == rawID }) else { return nil }
            return Combatent(
                name: player.name,
                currentHP: player.currentHP,
                maxHP: player.maxHP,
                initiative: player.initiative,
                isTurn: false,
                status: player.status,
                spellSlotCount: player.spellSlots.reduce(0) { $0 + $1.count }
            )
        }
        if sidebarID.hasPrefix("monster-") {
            let rawID = String(sidebarID.dropFirst("monster-".count))
            guard let monster = testMonsters.first(where: { $0.id.uuidString == rawID }) else { return nil }
            return Combatent(
                name: monster.name,
                currentHP: monster.currentHP,
                maxHP: monster.maxHP,
                initiative: monster.initiative,
                isTurn: false,
                status: monster.status,
                spellSlotCount: 0
            )
        }
        if sidebarID.hasPrefix("character-") {
            let rawID = String(sidebarID.dropFirst("character-".count))
            guard let npc = testNPCs.first(where: { $0.id.uuidString == rawID }) else { return nil }
            return Combatent(
                name: npc.name,
                currentHP: npc.currentHP,
                maxHP: npc.maxHP,
                initiative: npc.initiative,
                isTurn: false,
                status: npc.status,
                spellSlotCount: npc.spellSlots.reduce(0) { $0 + $1.count }
            )
        }
        return nil
    }
}

// MARK: - Views

struct PlayerCharacterDetailView: View {
    let player: PlayerCharacter

    private var activeStatuses: [statusCondition] {
        player.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.title2)
                    .fontWeight(.bold)

                Text("HP \(player.currentHP)/\(player.maxHP)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            DetailSection(title: "Statuses") {
                if activeStatuses.isEmpty {
                    Text("No active statuses")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activeStatuses, id: \.name) { status in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(status.name)
                                .font(.headline)

                            Text(status.effect)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(status.desc)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }

            DetailSection(title: "Spell Slots") {
                if player.spellSlots.isEmpty {
                    Text("No spell slots")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(player.spellSlots, id: \.level) { slot in
                        HStack {
                            Text("Level \(slot.level)")
                            Spacer()
                            Text("\(slot.count)")
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            content
        }
    }
}

struct InitiativeCard: View {
    var combatent: Combatent

    private var activeStatuses: [statusCondition] {
        combatent.status ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(combatent.name)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                Text("\(Int(combatent.initiative))")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            Text("HP: \(combatent.currentHP)/\(combatent.maxHP)")
                .font(.subheadline)

            if !activeStatuses.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Statuses")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(activeStatuses, id: \.name) { status in
                        Text(status.name)
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .frame(width: 220, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(combatent.isTurn ? Color.orange : Color.secondary.opacity(0.2), lineWidth: combatent.isTurn ? 2 : 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
    ContentView()
}
