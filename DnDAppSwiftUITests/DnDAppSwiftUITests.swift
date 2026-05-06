import Foundation
import Testing
@testable import DnDAppSwiftUI

@Suite(.serialized)
struct DnDAppSwiftUITests {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()

    @MainActor
    private func makeViewModel() -> CampaignViewModel {
        CampaignViewModel(dataService: CampaignDataService.shared)
    }

    @MainActor
    private func withRestoredDemoData(_ body: () throws -> Void) rethrows {
        let originalPlayers = testPlayers
        let originalMonsters = testMonsters
        let originalNPCs = testNPCs
        defer {
            testPlayers = originalPlayers
            testMonsters = originalMonsters
            testNPCs = originalNPCs
        }
        try body()
    }

    private func roundTrip(_ message: CampaignNetworkMessage, sessionID: UUID) throws -> CampaignNetworkMessage {
        let envelope = CampaignNetworkEnvelope(sessionID: sessionID, message: message)
        let data = try encoder.encode(envelope)
        let decoded = try decoder.decode(CampaignNetworkEnvelope.self, from: data)
        return decoded.message
    }

    @Test
    func welcomeMessageRoundTrip() throws {
        let welcome = CampaignNetworkWelcome(
            sessionID: UUID(),
            sessionName: "Test Session",
            protocolVersion: 2,
            currentRevision: 12,
            heartbeatIntervalMs: 10_000,
            deltaRetentionLimit: 500
        )

        let result = try roundTrip(.welcome(welcome), sessionID: CampaignNetworkEnvelope.preSessionID)
        guard case .welcome(let decoded) = result else {
            Issue.record("Expected welcome")
            return
        }

        #expect(decoded == welcome)
    }

    @Test
    func commandAndDeltaRoundTrip() throws {
        let playerID = UUID()
        let clientID = UUID()
        let command = CampaignCommandEnvelope(
            commandID: UUID(),
            clientID: clientID,
            baseRevision: 7,
            command: .setHitPoints(playerID: playerID, currentHP: 18, temporaryHP: 3)
        )
        let delta = CampaignDelta(
            deltaID: UUID(),
            revision: 8,
            previousRevision: 7,
            createdAt: Date(),
            originClientID: clientID,
            changes: [
                .playerHitPointsChanged(playerID: playerID, currentHP: 18, temporaryHP: 3)
            ]
        )

        let commandResult = try roundTrip(.command(command), sessionID: UUID())
        guard case .command(let decodedCommand) = commandResult else {
            Issue.record("Expected command")
            return
        }
        #expect(decodedCommand == command)

        let deltaResult = try roundTrip(.delta(delta), sessionID: UUID())
        guard case .delta(let decodedDelta) = deltaResult else {
            Issue.record("Expected delta")
            return
        }
        #expect(decodedDelta.deltaID == delta.deltaID)
        #expect(decodedDelta.revision == delta.revision)
        #expect(decodedDelta.previousRevision == delta.previousRevision)
        #expect(decodedDelta.originClientID == delta.originClientID)
        #expect(decodedDelta.changes == delta.changes)
    }

    @Test
    @MainActor
    func snapshotBuildIncludesRevisionAndAssignments() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let assignment = PlayerAssignment(
                clientID: UUID(),
                playerCharacterID: testPlayers[0].id,
                assignedByHostAt: Date()
            )

            let snapshot = CampaignSnapshotBuilder.build(
                from: viewModel,
                assignments: [assignment],
                revision: 42
            )

            #expect(snapshot.schemaVersion == 2)
            #expect(snapshot.revision == 42)
            #expect(snapshot.state.assignments == [assignment])
            #expect(snapshot.state.players.count == testPlayers.count)
            #expect(snapshot.state.combatents.count == viewModel.combatents.count)
        }
    }

    @Test
    @MainActor
    func mutationReducerClampsHitPointsAndEmitsCombatentChange() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]
            let clientID = UUID()
            let assignment = PlayerAssignment(clientID: clientID, playerCharacterID: player.id, assignedByHostAt: Date())

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [assignment])
            state.combatents.append(NetworkCombatent(
                id: UUID(), name: player.name,
                currentHP: player.currentHP, maxHP: player.maxHP,
                temporaryHP: 0, initiative: player.initiative,
                isTurn: false, status: nil,
                creatureType: player.race,
                spellSlots: player.spellSlots.map { NetworkSpellSlot(from: $0) },
                speed: NetworkMovementSpeed(from: player.speed),
                sourceSidebarID: "player-\(player.id.uuidString)",
                sourceEntityID: player.id,
                sourceEntityType: "player",
                isLairAction: false
            ))

            let changes = try CampaignMutationReducer.apply(
                .setHitPoints(playerID: player.id, currentHP: player.maxHP + 99, temporaryHP: -4),
                from: clientID,
                to: &state,
                assignments: [assignment]
            )

            let playerState = state.players.first { UUID(uuidString: $0.id) == player.id }
            #expect(playerState?.currentHP == player.maxHP)

            let combatentState = state.combatents.first { $0.sourceEntityID == player.id }
            #expect(combatentState?.currentHP == player.maxHP)
            #expect(combatentState?.temporaryHP == 0)

            #expect(changes.contains {
                if case .playerHitPointsChanged(let changedPlayerID, let currentHP, let temporaryHP) = $0 {
                    return changedPlayerID == player.id && currentHP == player.maxHP && temporaryHP == 0
                }
                return false
            })
            #expect(changes.contains {
                if case .combatentHitPointsChanged(let combatentID, let currentHP, let temporaryHP) = $0 {
                    return combatentID == combatentState?.id && currentHP == player.maxHP && temporaryHP == 0
                }
                return false
            })
        }
    }

    @Test
    @MainActor
    func mutationReducerRejectsUnassignedClient() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]
            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])

            #expect(throws: CampaignMutationReducer.ValidationError.self) {
                try CampaignMutationReducer.apply(
                    .setHitPoints(playerID: player.id, currentHP: 1, temporaryHP: 0),
                    from: UUID(),
                    to: &state,
                    assignments: []
                )
            }
        }
    }

    @Test
    @MainActor
    func deltaApplierAppliesAssignmentAndRollInsertion() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let assignment = PlayerAssignment(
                clientID: UUID(),
                playerCharacterID: testPlayers[1].id,
                assignedByHostAt: Date()
            )
            let entry = NetworkRollEntry(
                from: RollEntry(
                    type: "Attack",
                    name: "Test Blade",
                    roll: 14,
                    modifier: 5,
                    total: 19,
                    timestamp: Date()
                )
            )
            let delta = CampaignDelta(
                deltaID: UUID(),
                revision: 3,
                previousRevision: 2,
                createdAt: Date(),
                originClientID: assignment.clientID,
                changes: [
                    .assignmentChanged(assignment),
                    .rollInserted(entry: entry, position: "front")
                ]
            )

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            CampaignDeltaApplier.apply(delta, to: &state)
            CampaignSnapshotBuilder.writeState(state, to: viewModel)

            #expect(viewModel.networkAssignments == [assignment])
            #expect(viewModel.rollHistory.count == 1)
            #expect(viewModel.rollHistory[0].name == "Test Blade")
        }
    }

    @Test
    @MainActor
    func networkingServiceReplaysContiguousDeltas() throws {
        let service = CampaignNetworkingService()
        service.sessionID = UUID()

        let first = service.makeDelta(
            originClientID: nil,
            changes: [.rollInserted(
                entry: NetworkRollEntry(
                    from: RollEntry(type: "Test", name: "First", roll: 1, modifier: 0, total: 1, timestamp: Date())
                ),
                position: "front"
            )]
        )
        service.broadcastDelta(first)

        let second = service.makeDelta(
            originClientID: nil,
            changes: [.rollInserted(
                entry: NetworkRollEntry(
                    from: RollEntry(type: "Test", name: "Second", roll: 2, modifier: 0, total: 2, timestamp: Date())
                ),
                position: "front"
            )]
        )
        service.broadcastDelta(second)

        let replay = service.replayBatch(from: 0)
        #expect(replay?.fromRevision == 1)
        #expect(replay?.toRevision == 2)
        #expect(replay?.deltas.count == 2)
        #expect(replay?.deltas.map(\.revision) == [1, 2])
    }

    @Test
    func networkCombatentStatusRoundTripPreservesNilVsEmpty() throws {
        let combatentNil = Combatent(
            name: "Test", currentHP: 10, maxHP: 10,
            initiative: 0, isTurn: false,
            status: nil, spellSlots: [],
            speed: MovementSpeed(walk: 30)
        )
        let combatentEmpty = Combatent(
            name: "Test", currentHP: 10, maxHP: 10,
            initiative: 0, isTurn: false,
            status: [], spellSlots: [],
            speed: MovementSpeed(walk: 30)
        )

        let networkNil = NetworkCombatent(from: combatentNil)
        let networkEmpty = NetworkCombatent(from: combatentEmpty)

        #expect(networkNil.status == nil)
        #expect(networkEmpty.status != nil)
        #expect(networkEmpty.status?.isEmpty == true)

        let roundTrippedNil = networkNil.toCombatent()
        let roundTrippedEmpty = networkEmpty.toCombatent()

        #expect(roundTrippedNil.status == nil)
        #expect(roundTrippedEmpty.status != nil)
        #expect(roundTrippedEmpty.status?.isEmpty == true)
    }

    @Test
    func networkCombatentTypedEntityReferenceRoundTrip() throws {
        let entityID = UUID()
        let combatent = Combatent(
            name: "Test", currentHP: 10, maxHP: 10,
            initiative: 0, isTurn: false,
            status: nil, spellSlots: [],
            speed: MovementSpeed(walk: 30),
            sourceSidebarID: "player-\(entityID.uuidString)",
            sourceEntityID: entityID,
            sourceEntityType: .player
        )

        let network = NetworkCombatent(from: combatent)
        #expect(network.sourceEntityID == entityID)
        #expect(network.sourceEntityType == "player")

        let roundTripped = network.toCombatent()
        #expect(roundTripped.sourceEntityID == entityID)
        #expect(roundTripped.sourceEntityType == .player)
    }

    @Test
    @MainActor
    func deltaApplierUsesTypedCombatentLookup() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            let combatentID = UUID()
            state.combatents.append(NetworkCombatent(
                id: combatentID, name: player.name,
                currentHP: player.currentHP, maxHP: player.maxHP,
                temporaryHP: 0, initiative: player.initiative,
                isTurn: false, status: nil,
                creatureType: player.race,
                spellSlots: player.spellSlots.map { NetworkSpellSlot(from: $0) },
                speed: NetworkMovementSpeed(from: player.speed),
                sourceSidebarID: "player-\(player.id.uuidString)",
                sourceEntityID: player.id,
                sourceEntityType: "player",
                isLairAction: false
            ))

            let hpDelta = CampaignDelta(
                deltaID: UUID(),
                revision: 1,
                previousRevision: 0,
                createdAt: Date(),
                originClientID: nil,
                changes: [
                    .playerHitPointsChanged(playerID: player.id, currentHP: 5, temporaryHP: 2)
                ]
            )
            CampaignDeltaApplier.apply(hpDelta, to: &state)

            let updatedPlayer = state.players.first { UUID(uuidString: $0.id) == player.id }
            #expect(updatedPlayer?.currentHP == 5)

            let statusDelta = CampaignDelta(
                deltaID: UUID(),
                revision: 2,
                previousRevision: 1,
                createdAt: Date(),
                originClientID: nil,
                changes: [
                    .playerStatusesChanged(playerID: player.id, statuses: [
                        NetworkStatusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Has disadvantage")
                    ])
                ]
            )
            CampaignDeltaApplier.apply(statusDelta, to: &state)

            let updatedPlayer2 = state.players.first { UUID(uuidString: $0.id) == player.id }
            #expect(updatedPlayer2?.status?.count == 1)
            #expect(updatedPlayer2?.status?.first?.name == "Poisoned")
        }
    }

    @Test
    @MainActor
    func fullReducerToApplierRoundTrip() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]
            let clientID = UUID()
            let assignment = PlayerAssignment(clientID: clientID, playerCharacterID: player.id, assignedByHostAt: Date())

            var hostState = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [assignment])
            hostState.combatents.append(NetworkCombatent(
                id: UUID(), name: player.name,
                currentHP: player.currentHP, maxHP: player.maxHP,
                temporaryHP: 0, initiative: player.initiative,
                isTurn: false, status: nil,
                creatureType: player.race,
                spellSlots: player.spellSlots.map { NetworkSpellSlot(from: $0) },
                speed: NetworkMovementSpeed(from: player.speed),
                sourceSidebarID: "player-\(player.id.uuidString)",
                sourceEntityID: player.id,
                sourceEntityType: "player",
                isLairAction: false
            ))

            let changes = try CampaignMutationReducer.apply(
                .setHitPoints(playerID: player.id, currentHP: 12, temporaryHP: 5),
                from: clientID,
                to: &hostState,
                assignments: [assignment]
            )

            let service = CampaignNetworkingService()
            service.sessionID = UUID()
            let delta = service.makeDelta(originClientID: clientID, changes: changes)

            var clientState = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            CampaignDeltaApplier.apply(delta, to: &clientState)

            let clientPlayer = clientState.players.first { UUID(uuidString: $0.id) == player.id }
            #expect(clientPlayer?.currentHP == 12)

            let hpChange = changes.first {
                if case .playerHitPointsChanged(let pid, let hp, let tmp) = $0 {
                    return pid == player.id && hp == 12 && tmp == 5
                }
                return false
            }
            #expect(hpChange != nil)
        }
    }

    @Test
    @MainActor
    func deltaBatchAppliesMultipleDeltasInOrder() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])

            let delta1 = CampaignDelta(
                deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil,
                changes: [.playerHitPointsChanged(playerID: player.id, currentHP: 20, temporaryHP: 0)]
            )
            let delta2 = CampaignDelta(
                deltaID: UUID(), revision: 2, previousRevision: 1, createdAt: Date(), originClientID: nil,
                changes: [.playerHitPointsChanged(playerID: player.id, currentHP: 10, temporaryHP: 3)]
            )
            let delta3 = CampaignDelta(
                deltaID: UUID(), revision: 3, previousRevision: 2, createdAt: Date(), originClientID: nil,
                changes: [.playerHitPointsChanged(playerID: player.id, currentHP: 5, temporaryHP: 0)]
            )

            CampaignDeltaApplier.apply(delta1, to: &state)
            CampaignDeltaApplier.apply(delta2, to: &state)
            CampaignDeltaApplier.apply(delta3, to: &state)

            let finalPlayer = state.players.first { UUID(uuidString: $0.id) == player.id }
            #expect(finalPlayer?.currentHP == 5)
            #expect(finalPlayer?.maxHP == player.maxHP)
        }
    }

    @Test
    @MainActor
    func deltaGapDetectionReturnsNilReplay() throws {
        let service = CampaignNetworkingService()
        service.sessionID = UUID()

        let delta1 = service.makeDelta(
            originClientID: nil,
            changes: [.rollInserted(
                entry: NetworkRollEntry(from: RollEntry(type: "Initiative", name: "Roll", roll: 15, modifier: 2, total: 17, timestamp: Date())),
                position: "front"
            )]
        )
        service.broadcastDelta(delta1)

        let deltaWithGap = CampaignDelta(
            deltaID: UUID(),
            revision: 5,
            previousRevision: 3,
            createdAt: Date(),
            originClientID: nil,
            changes: [.rollInserted(
                entry: NetworkRollEntry(from: RollEntry(type: "Attack", name: "Strike", roll: 18, modifier: 5, total: 23, timestamp: Date())),
                position: "front"
            )]
        )
        service.broadcastDelta(deltaWithGap)

        let replay = service.replayBatch(from: 0)
        #expect(replay == nil)
    }

    @Test
    @MainActor
    func deltaAppliesSpellSlotChange() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]
            guard !player.spellSlots.isEmpty else { return }

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            let slotLevel = player.spellSlots[0].level
            let originalAvailable = player.spellSlots[0].available

            let delta = CampaignDelta(
                deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil,
                changes: [.playerSpellSlotChanged(playerID: player.id, level: slotLevel, available: originalAvailable - 1)]
            )
            CampaignDeltaApplier.apply(delta, to: &state)

            let updatedPlayer = state.players.first { UUID(uuidString: $0.id) == player.id }
            let updatedSlot = updatedPlayer?.spellSlots.first { $0.level == slotLevel }
            #expect(updatedSlot?.available == originalAvailable - 1)
        }
    }

    @Test
    @MainActor
    func deltaAppliesCombatentStatusChange() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let combatentID = UUID()

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            state.combatents.append(NetworkCombatent(
                id: combatentID, name: "Goblin",
                currentHP: 7, maxHP: 7, temporaryHP: 0, initiative: 12,
                isTurn: false, status: nil,
                creatureType: "Humanoid",
                spellSlots: [],
                speed: NetworkMovementSpeed(walk: 30),
                sourceSidebarID: nil, sourceEntityID: nil, sourceEntityType: nil,
                isLairAction: false
            ))

            let statuses = [
                NetworkStatusCondition(name: "Frightened", effect: "Can't move closer", desc: "Disadvantage on ability checks"),
                NetworkStatusCondition(name: "Poisoned", effect: "Disadvantage", desc: "Has disadvantage on attacks")
            ]

            let delta = CampaignDelta(
                deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil,
                changes: [.combatentStatusesChanged(combatentID: combatentID, statuses: statuses)]
            )
            CampaignDeltaApplier.apply(delta, to: &state)

            let updatedCombatent = state.combatents.first { $0.id == combatentID }
            #expect(updatedCombatent?.status?.count == 2)
            #expect(updatedCombatent?.status?.first?.name == "Frightened")
        }
    }

    @Test
    @MainActor
    func deltaAppliesCombatentSpellSlotChange() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let combatentID = UUID()

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            state.combatents.append(NetworkCombatent(
                id: combatentID, name: "Mage",
                currentHP: 22, maxHP: 22, temporaryHP: 0, initiative: 8,
                isTurn: false, status: nil,
                creatureType: "Humanoid",
                spellSlots: [
                    NetworkSpellSlot(level: 1, max: 4, available: 4),
                    NetworkSpellSlot(level: 2, max: 3, available: 3)
                ],
                speed: NetworkMovementSpeed(walk: 30),
                sourceSidebarID: nil, sourceEntityID: nil, sourceEntityType: nil,
                isLairAction: false
            ))

            let delta = CampaignDelta(
                deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil,
                changes: [.combatentSpellSlotChanged(combatentID: combatentID, level: 2, available: 1)]
            )
            CampaignDeltaApplier.apply(delta, to: &state)

            let updatedCombatent = state.combatents.first { $0.id == combatentID }
            let slot = updatedCombatent?.spellSlots.first { $0.level == 2 }
            #expect(slot?.available == 1)
            #expect(slot?.max == 3)
        }
    }

    @Test
    @MainActor
    func deltaAppliesInventoryEquipChange() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let playerID = testPlayers[0].id
            let inventoryItemID = UUID()

            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])
            state.playerInventories[playerID.uuidString] = [
                NetworkInventoryItem(id: inventoryItemID, lootItemID: "ring-of-protection", isEquipped: false)
            ]

            let delta = CampaignDelta(
                deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil,
                changes: [.playerInventoryItemEquippedChanged(playerID: playerID, inventoryItemID: inventoryItemID, isEquipped: true)]
            )
            CampaignDeltaApplier.apply(delta, to: &state)

            let items = state.playerInventories[playerID.uuidString]
            #expect(items?.first?.isEquipped == true)
        }
    }

    @Test
    @MainActor
    func deltaAppliesRollInsertedAtFront() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            var state = CampaignSnapshotBuilder.readCurrentState(from: viewModel, assignments: [])

            let entry1 = NetworkRollEntry(from: RollEntry(type: "Initiative", name: "Wizard", roll: 15, modifier: 2, total: 17, timestamp: Date()))
            let entry2 = NetworkRollEntry(from: RollEntry(type: "Attack", name: "Wizard", roll: 18, modifier: 5, total: 23, timestamp: Date()))

            let delta1 = CampaignDelta(deltaID: UUID(), revision: 1, previousRevision: 0, createdAt: Date(), originClientID: nil, changes: [.rollInserted(entry: entry1, position: "front")])
            let delta2 = CampaignDelta(deltaID: UUID(), revision: 2, previousRevision: 1, createdAt: Date(), originClientID: nil, changes: [.rollInserted(entry: entry2, position: "front")])

            CampaignDeltaApplier.apply(delta1, to: &state)
            CampaignDeltaApplier.apply(delta2, to: &state)

            #expect(state.rollHistory.count == 2)
            #expect(state.rollHistory[0].name == "Wizard")
            #expect(state.rollHistory[0].roll == 18)
            #expect(state.rollHistory[1].roll == 15)
        }
    }

    @Test
    @MainActor
    func commandReceiptsEvictOldestWhenOverLimit() throws {
        let service = CampaignNetworkingService()
        let clientID = UUID()

        for i in 0..<1005 {
            let receipt = CampaignCommandAccepted(commandID: UUID(), appliedRevision: i, appliedAt: Date())
            service.recordAcceptedReceipt(receipt, for: clientID, commandID: UUID())
        }

        let receipts = service.receiptsForTesting(clientID: clientID)
        #expect(receipts.count == 1000)
    }

    @Test
    @MainActor
    func snapshotRoundTripPreservesAllEntityStates() throws {
        try withRestoredDemoData {
            let viewModel = makeViewModel()
            let player = testPlayers[0]
            let clientID = UUID()
            let assignment = PlayerAssignment(clientID: clientID, playerCharacterID: player.id, assignedByHostAt: Date())

            viewModel.combatents = [
                Combatent(
                    name: player.name,
                    currentHP: player.currentHP,
                    maxHP: player.maxHP,
                    initiative: player.initiative,
                    isTurn: false,
                    spellSlots: player.spellSlots,
                    speed: player.speed,
                    sourceSidebarID: "player-\(player.id.uuidString)",
                    sourceEntityID: player.id,
                    sourceEntityType: .player
                )
            ]

            let snapshot = CampaignSnapshotBuilder.build(from: viewModel, assignments: [assignment], revision: 1)

            let freshVM = makeViewModel()
            CampaignSnapshotBuilder.apply(snapshot, to: freshVM)

            #expect(freshVM.combatents.count == 1)
            #expect(freshVM.combatents[0].name == player.name)
            #expect(freshVM.combatents[0].sourceEntityID == player.id)
            #expect(freshVM.combatents[0].sourceEntityType == .player)
            #expect(freshVM.networkAssignments == [assignment])
        }
    }
}
