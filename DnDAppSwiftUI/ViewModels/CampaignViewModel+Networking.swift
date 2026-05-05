import Foundation

extension CampaignViewModel {

    // MARK: - Host API

    func startHostingCampaignSession(name: String) {
        networkingService.startHosting(sessionID: UUID(), sessionName: name) { [weak self] envelope, clientID in
            Task { @MainActor [weak self] in
                self?.handleHostMessage(envelope, fromClient: clientID)
            }
        }
    }

    func stopNetworking() {
        publishWorkItem?.cancel()
        publishWorkItem = nil
        networkAssignments.removeAll()
        networkingService.stop()
    }

    // MARK: - Client API

    func startBrowsingCampaignSessions() {
        networkingService.startBrowsing { [weak self] envelope, _ in
            Task { @MainActor [weak self] in
                self?.handleClientMessage(envelope)
            }
        }
    }

    func connectToCampaignSession(_ peer: CampaignPeer) {
        networkingService.connect(to: peer)
    }

    // MARK: - Assignment (Host)

    func assignPlayerCharacter(_ playerID: UUID, to clientID: UUID) {
        networkAssignments.removeAll { $0.clientID == clientID }

        let assignment = PlayerAssignment(
            clientID: clientID,
            playerCharacterID: playerID,
            assignedByHostAt: Date()
        )
        networkAssignments.append(assignment)

        if let connID = networkingService.connectionID(forClientID: clientID) {
            networkingService.connectedClients[connID]?.assignedPlayerID = playerID
            let delta = networkingService.makeDelta(
                originClientID: nil,
                changes: [.assignmentChanged(assignment)]
            )
            networkingService.broadcastDelta(delta)
            networkingService.send(.assignmentChanged(assignment), to: connID)
        }
    }

    func unassignPlayerCharacter(from clientID: UUID) {
        networkAssignments.removeAll { $0.clientID == clientID }
        if let connID = networkingService.connectionID(forClientID: clientID) {
            networkingService.connectedClients[connID]?.assignedPlayerID = nil
        }
        publishNetworkSnapshot(reason: "player unassigned")
    }

    // MARK: - Client Commands

    func sendAssignedPlayerUpdate(_ command: PlayerCharacterUpdateCommand) {
        guard networkingService.role == .client else { return }
        let envelope = CampaignCommandEnvelope(
            clientID: networkingService.clientID,
            baseRevision: networkingService.lastAppliedRevision,
            command: command
        )
        networkingService.sendToHost(.command(envelope))
    }

    // MARK: - Snapshot Publishing

    func publishNetworkSnapshot(reason: String) {
        guard networkingService.role == .host else { return }

        publishWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.networkingService.currentRevision += 1
                let snapshot = self.makeNetworkSnapshot()
                self.networkingService.sendSnapshot(snapshot)
            }
        }
        publishWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: workItem)
    }

    func makeNetworkSnapshot() -> CampaignNetworkSnapshot {
        CampaignSnapshotBuilder.build(
            from: self,
            assignments: networkAssignments,
            revision: networkingService.currentRevision
        )
    }

    func applyNetworkSnapshot(_ snapshot: CampaignNetworkSnapshot) {
        CampaignSnapshotBuilder.apply(snapshot, to: self)
        networkingService.noteSnapshotApplied(snapshot.revision)
    }

    // MARK: - Host Message Handler

    private func handleHostMessage(_ envelope: CampaignNetworkEnvelope, fromClient clientID: UUID?) {
        switch envelope.message {
        case .hello:
            break

        case .requestSnapshot:
            if let clientID, let connID = networkingService.connectionID(forClientID: clientID) {
                networkingService.sendSnapshot(makeNetworkSnapshot(), to: connID)
            }

        case .resumeSession(let resume):
            guard let clientID, let connID = networkingService.connectionID(forClientID: clientID) else {
                return
            }
            if let replay = networkingService.replayBatch(from: resume.lastAppliedRevision) {
                networkingService.send(.deltaBatch(replay), to: connID)
            } else {
                networkingService.sendSnapshot(makeNetworkSnapshot(), to: connID)
            }

        case .command(let commandEnvelope):
            guard let clientID else { return }
            applyValidatedPlayerUpdate(commandEnvelope, from: clientID)

        case .ping(let id):
            if let clientID, let connID = networkingService.connectionID(forClientID: clientID) {
                networkingService.send(.pong(id), to: connID)
            }

        default:
            break
        }
    }

    // MARK: - Client Message Handler

    private func handleClientMessage(_ envelope: CampaignNetworkEnvelope) {
        switch envelope.message {
        case .welcome(let welcome):
            networkingService.sessionID = welcome.sessionID
            networkingService.currentRevision = welcome.currentRevision
            networkingService.markSyncing()

            if networkingService.lastAppliedRevision > 0 {
                networkingService.sendToHost(.resumeSession(
                    CampaignResumeSession(
                        clientID: networkingService.clientID,
                        lastAppliedRevision: networkingService.lastAppliedRevision
                    )
                ))
            } else {
                networkingService.sendToHost(.requestSnapshot)
            }

        case .snapshot(let snapshot):
            applyNetworkSnapshot(snapshot)

        case .delta(let delta):
            guard delta.previousRevision == networkingService.lastAppliedRevision else {
                networkingService.markStale()
                networkingService.sendToHost(.requestSnapshot)
                return
            }
            CampaignDeltaApplier.apply(delta, to: self)
            networkingService.noteDeltaApplied(delta.revision)

        case .deltaBatch(let batch):
            for delta in batch.deltas.sorted(by: { $0.revision < $1.revision }) {
                guard delta.previousRevision == networkingService.lastAppliedRevision else {
                    networkingService.markStale()
                    networkingService.sendToHost(.requestSnapshot)
                    return
                }
                CampaignDeltaApplier.apply(delta, to: self)
                networkingService.noteDeltaApplied(delta.revision)
            }

        case .assignmentChanged(let assignment):
            networkAssignments.removeAll { $0.clientID == assignment.clientID }
            networkAssignments.append(assignment)

        case .commandAccepted:
            break

        case .commandRejected(let rejection):
            networkingService.lastError = "Update rejected: \(rejection.reason)"

        case .pong:
            break

        case .error(let message):
            networkingService.lastError = "Host error: \(message.message)"

        default:
            break
        }
    }

    // MARK: - Host Command Validation

    func applyValidatedPlayerUpdate(
        _ envelope: CampaignCommandEnvelope,
        from clientID: UUID
    ) {
        if let priorResult = networkingService.receipt(for: clientID, commandID: envelope.commandID) {
            if let connID = networkingService.connectionID(forClientID: clientID) {
                if let accepted = priorResult.accepted {
                    networkingService.send(.commandAccepted(accepted), to: connID)
                } else if let rejected = priorResult.rejected {
                    networkingService.send(.commandRejected(rejected), to: connID)
                }
            }
            return
        }

        do {
            let changes = try CampaignMutationReducer.apply(
                envelope.command,
                from: clientID,
                to: self,
                assignments: networkAssignments
            )
            let delta = networkingService.makeDelta(originClientID: clientID, changes: changes)
            networkingService.broadcastDelta(delta)
            acceptUpdate(commandID: envelope.commandID, appliedRevision: delta.revision, to: clientID)
        } catch let error as CampaignMutationReducer.ValidationError {
            switch error {
            case .rejected(let code, let reason):
                rejectUpdate(commandID: envelope.commandID, to: clientID, code: code, reason: reason)
            }
        } catch {
            rejectUpdate(
                commandID: envelope.commandID,
                to: clientID,
                code: "unknownError",
                reason: error.localizedDescription
            )
        }
    }

    private func rejectUpdate(commandID: UUID, to clientID: UUID, code: String, reason: String) {
        let rejection = CampaignCommandRejected(
            commandID: commandID,
            rejectedAt: Date(),
            code: code,
            reason: reason
        )
        networkingService.recordRejectedReceipt(rejection, for: clientID, commandID: commandID)
        if let connID = networkingService.connectionID(forClientID: clientID) {
            networkingService.send(.commandRejected(rejection), to: connID)
        }
    }

    private func acceptUpdate(commandID: UUID, appliedRevision: Int, to clientID: UUID) {
        let receipt = CampaignCommandAccepted(
            commandID: commandID,
            appliedRevision: appliedRevision,
            appliedAt: Date()
        )
        networkingService.recordAcceptedReceipt(receipt, for: clientID, commandID: commandID)
        if let connID = networkingService.connectionID(forClientID: clientID) {
            networkingService.send(.commandAccepted(receipt), to: connID)
        }
    }
}
