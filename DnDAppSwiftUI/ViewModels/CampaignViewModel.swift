import SwiftUI
import Observation

@Observable
@MainActor
final class CampaignViewModel {
    var selectedItemID: String? = "players"
    var combatents: [Combatent] = []
    var selectedInitiativeCombatentID: Combatent.ID?
    var isInitiativeTargeted = false
    var editingCombatentID: Combatent.ID?
    var isStatusPalettePresented = false
    var pendingStatus: StatusCondition?

    private let dataService: CampaignDataService

    init(dataService: CampaignDataService) {
        self.dataService = dataService
    }

    // MARK: - Computed

    var statusPaletteButtonTitle: String {
        pendingStatus.map { "Assign \($0.name)" } ?? "Statuses"
    }

    var statusPaletteHelpText: String {
        pendingStatus.map { "Click an initiative card to assign \($0.name)" } ?? "Statuses"
    }

    var assignableStatuses: [StatusCondition] {
        let all = defaultStatusConditions
            + testPlayers.flatMap { $0.status ?? [] }
            + testMonsters.flatMap { $0.status ?? [] }
            + testNPCs.flatMap { $0.status ?? [] }
            + testCombatents.flatMap { $0.status ?? [] }
            + combatents.flatMap { $0.status ?? [] }
        return uniqueStatuses(from: all)
    }

    var selectedInitiativeCombatent: Combatent? {
        guard let selectedInitiativeCombatentID else { return nil }
        return combatents.first { $0.id == selectedInitiativeCombatentID }
    }

    var selectedSidebarItem: SidebarItem? {
        dataService.sidebarItem(withID: selectedItemID, in: sidebarItems)
    }

    var selectedPlayer: PlayerCharacter? {
        dataService.player(for: selectedItemID)
    }

    var selectedMonster: Monster? {
        dataService.monster(for: selectedItemID)
    }

    var selectedNPC: NPC? {
        dataService.npc(for: selectedItemID)
    }

    var editingCombatent: Binding<Combatent>? {
        guard let editingCombatentID else { return nil }
        return Binding {
            self.combatents.first { $0.id == editingCombatentID } ?? Combatent(
                name: "",
                currentHP: 0,
                maxHP: 0,
                initiative: 0,
                isTurn: false,
                status: nil,
                creatureType: nil,
                spellSlots: [],
                speed: MovementSpeed(walk: 0)
            )
        } set: { updatedCombatent in
            guard let index = self.combatents.firstIndex(where: { $0.id == editingCombatentID }) else { return }
            self.combatents[index] = updatedCombatent
        }
    }

    // MARK: - Actions

    func selectSidebarItem(_ id: String?) {
        selectedItemID = id
        selectedInitiativeCombatentID = nil
    }

    func addCombatents(from sidebarIDs: [String]) -> Bool {
        var added: [Combatent] = []
        for id in sidebarIDs {
            if id.hasPrefix("player-") {
                let existsInTracker = combatents.contains { $0.sourceSidebarID == id }
                let existsInAdded = added.contains { $0.sourceSidebarID == id }
                if existsInTracker || existsInAdded { continue }
            }
            if let newCombatent = dataService.makeCombatent(from: id) {
                added.append(newCombatent)
            }
        }
        combatents.append(contentsOf: added)
        combatents.sort { $0.initiative > $1.initiative }
        return !added.isEmpty
    }

    func selectOrAssignStatus(to combatent: Combatent) {
        selectedInitiativeCombatentID = combatent.id
        if let sourceSidebarID = combatent.sourceSidebarID {
            selectedItemID = sourceSidebarID
        }
        guard let pendingStatus else { return }
        assignStatus(pendingStatus, to: combatent.id)
        self.pendingStatus = nil
    }

    func assignDraggedStatus(from payloads: [String], to combatentID: Combatent.ID) -> Bool {
        let statuses = payloads.compactMap(statusFromDragPayload)
        for status in statuses {
            assignStatus(status, to: combatentID)
        }
        return !statuses.isEmpty
    }

    func longRest() {
        for index in combatents.indices {
            combatents[index].currentHP = combatents[index].maxHP
            combatents[index].status = nil
            for slotIndex in combatents[index].spellSlots.indices {
                combatents[index].spellSlots[slotIndex].available = combatents[index].spellSlots[slotIndex].max
            }
        }
        for index in testPlayers.indices {
            testPlayers[index].currentHP = testPlayers[index].maxHP
            testPlayers[index].status = nil
            for slotIndex in testPlayers[index].spellSlots.indices {
                testPlayers[index].spellSlots[slotIndex].available = testPlayers[index].spellSlots[slotIndex].max
            }
        }
    }

    func beginEditing(combatentID: Combatent.ID) {
        editingCombatentID = combatentID
    }

    func dismissEditor() {
        editingCombatentID = nil
    }

    func removeCombatent(id: Combatent.ID) {
        combatents.removeAll { $0.id == id }
        if selectedInitiativeCombatentID == id {
            selectedInitiativeCombatentID = nil
        }
        if editingCombatentID == id {
            editingCombatentID = nil
        }
    }

    func addLairAction() {
        let lairAction = Combatent(
            name: "Lair Action",
            currentHP: 0,
            maxHP: 0,
            initiative: 20,
            isTurn: false,
            status: nil,
            creatureType: "Lair Action",
            spellSlots: [],
            speed: MovementSpeed(walk: 0),
            isLairAction: true
        )
        combatents.append(lairAction)
        combatents.sort { $0.initiative > $1.initiative }
    }

    func queueStatus(_ status: StatusCondition) {
        pendingStatus = status
        isStatusPalettePresented = false
    }

    // MARK: - Private

    private func assignStatus(_ status: StatusCondition, to combatentID: Combatent.ID) {
        guard let index = combatents.firstIndex(where: { $0.id == combatentID }) else { return }
        var statuses = combatents[index].status ?? []
        if !statuses.contains(where: { $0.name == status.name }) {
            statuses.append(status)
        }
        combatents[index].status = statuses
    }

    private func statusFromDragPayload(_ payload: String) -> StatusCondition? {
        guard payload.hasPrefix(statusDragPayloadPrefix) else { return nil }
        let statusName = String(payload.dropFirst(statusDragPayloadPrefix.count))
        return assignableStatuses.first { $0.name == statusName }
    }

    private func uniqueStatuses(from statuses: [StatusCondition]) -> [StatusCondition] {
        var seenNames: Set<String> = []
        return statuses.filter { status in
            if seenNames.contains(status.name) { return false }
            seenNames.insert(status.name)
            return true
        }
    }
}

private let statusDragPayloadPrefix = "status:"

func statusDragPayload(for status: StatusCondition) -> String {
    "\(statusDragPayloadPrefix)\(status.name)"
}
