import Foundation

// MARK: - Status palette & assignment

extension CampaignViewModel {
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

    func queueStatus(_ status: StatusCondition) {
        pendingStatus = status
        isStatusPalettePresented = false
    }

    func selectOrAssignStatus(to combatent: Combatent) {
        selectedInitiativeCombatentID = combatent.id
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

    private func assignStatus(_ status: StatusCondition, to combatentID: Combatent.ID) {
        guard let index = combatents.firstIndex(where: { $0.id == combatentID }) else { return }
        var statuses = combatents[index].status ?? []
        if !statuses.contains(where: { $0.name == status.name }) {
            statuses.append(status)
        }
        combatents[index].status = statuses
        publishNetworkSnapshot(reason: "status assigned")
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

// MARK: - Drag payload helpers

private let statusDragPayloadPrefix = "status:"

func statusDragPayload(for status: StatusCondition) -> String {
    "\(statusDragPayloadPrefix)\(status.name)"
}
