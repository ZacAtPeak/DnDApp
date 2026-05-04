import SwiftUI

// MARK: - Initiative tracker

extension CampaignViewModel {
    var selectedInitiativeCombatent: Combatent? {
        guard let selectedInitiativeCombatentID else { return nil }
        return combatents.first { $0.id == selectedInitiativeCombatentID }
    }

    var combatentLinkedPlayer: PlayerCharacter? {
        dataService.player(for: selectedInitiativeCombatent?.sourceSidebarID)
    }

    var combatentLinkedMonster: Monster? {
        dataService.monster(for: selectedInitiativeCombatent?.sourceSidebarID)
    }

    var combatentLinkedNPC: NPC? {
        dataService.npc(for: selectedInitiativeCombatent?.sourceSidebarID)
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

    func addCombatents(from sidebarIDs: [String]) -> Bool {
        let expanded = sidebarIDs.flatMap { expandEncounter(sidebarID: $0) }
        var added: [Combatent] = []
        for id in expanded {
            if id.hasPrefix("player-") {
                let existsInTracker = combatents.contains { $0.sourceSidebarID == id }
                let existsInAdded = added.contains { $0.sourceSidebarID == id }
                if existsInTracker || existsInAdded { continue }
            }
            let initiative: Double
            if let participant = dataService.combatParticipant(for: id) {
                let details = dataService.initiativeRoll(for: participant.abilityScores)
                logRoll(
                    type: "Initiative",
                    name: participant.name,
                    roll: details.roll,
                    modifier: details.modifier,
                    total: details.total
                )
                initiative = details.total
            } else {
                initiative = 0
            }
            if let newCombatent = dataService.makeCombatent(from: id, initiative: initiative) {
                added.append(newCombatent)
            }
        }
        combatents.append(contentsOf: added)
        combatents.sort { $0.initiative > $1.initiative }
        return !added.isEmpty
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

    func advanceTurn() {
        guard !combatents.isEmpty else { return }
        let currentIndex = combatents.firstIndex(where: { $0.isTurn }) ?? -1
        let nextIndex = (currentIndex + 1) % combatents.count
        if currentIndex >= 0 {
            combatents[currentIndex].isTurn = false
        }
        combatents[nextIndex].isTurn = true
    }

    func rewindTurn() {
        guard !combatents.isEmpty else { return }
        let currentIndex = combatents.firstIndex(where: { $0.isTurn }) ?? combatents.count
        let prevIndex = (currentIndex - 1 + combatents.count) % combatents.count
        if currentIndex < combatents.count {
            combatents[currentIndex].isTurn = false
        }
        combatents[prevIndex].isTurn = true
    }

    func makeCurrentTurn(for combatentID: Combatent.ID) {
        for index in combatents.indices {
            combatents[index].isTurn = combatents[index].id == combatentID
        }
    }

    func beginEditing(combatentID: Combatent.ID) {
        editingCombatentID = combatentID
    }

    func dismissEditor() {
        editingCombatentID = nil
    }

    func isInTracker(sidebarID: String) -> Bool {
        combatents.contains { $0.sourceSidebarID == sidebarID }
    }

    private func expandEncounter(sidebarID: String) -> [String] {
        let prefix = "encounter-"
        guard sidebarID.hasPrefix(prefix) else { return [sidebarID] }

        // Encounter member: encounter-<uuid>-member-<memberID>
        if let memberRange = sidebarID.range(of: "-member-") {
            let memberID = String(sidebarID[memberRange.upperBound...])
            return [memberID]
        }

        // Encounter folder: encounter-<uuid>
        if let uuid = UUID(uuidString: String(sidebarID.dropFirst(prefix.count))),
           let encounter = encounters.first(where: { $0.id == uuid }) {
            return encounter.memberSidebarIDs
        }

        return [sidebarID]
    }

    func toggleTracker(sidebarID: String) {
        if let combatent = combatents.first(where: { $0.sourceSidebarID == sidebarID }) {
            removeCombatent(id: combatent.id)
        } else {
            _ = addCombatents(from: [sidebarID])
        }
    }
}
