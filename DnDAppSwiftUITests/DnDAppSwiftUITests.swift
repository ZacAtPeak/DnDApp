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

            viewModel.combatents = [
                Combatent(
                    name: player.name,
                    currentHP: player.currentHP,
                    maxHP: player.maxHP,
                    initiative: player.initiative,
                    isTurn: false,
                    spellSlots: player.spellSlots,
                    speed: player.speed,
                    sourceSidebarID: "player-\(player.id.uuidString)"
                )
            ]

            let changes = try CampaignMutationReducer.apply(
                .setHitPoints(playerID: player.id, currentHP: player.maxHP + 99, temporaryHP: -4),
                from: clientID,
                to: viewModel,
                assignments: [assignment]
            )

            #expect(testPlayers[0].currentHP == player.maxHP)
            #expect(viewModel.combatents[0].currentHP == player.maxHP)
            #expect(viewModel.combatents[0].temporaryHP == 0)
            #expect(changes.contains {
                if case .playerHitPointsChanged(let changedPlayerID, let currentHP, let temporaryHP) = $0 {
                    return changedPlayerID == player.id && currentHP == player.maxHP && temporaryHP == 0
                }
                return false
            })
            #expect(changes.contains {
                if case .combatentHitPointsChanged(let combatentID, let currentHP, let temporaryHP) = $0 {
                    return combatentID == viewModel.combatents[0].id && currentHP == player.maxHP && temporaryHP == 0
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

            #expect(throws: CampaignMutationReducer.ValidationError.self) {
                try CampaignMutationReducer.apply(
                    .setHitPoints(playerID: player.id, currentHP: 1, temporaryHP: 0),
                    from: UUID(),
                    to: viewModel,
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

            CampaignDeltaApplier.apply(delta, to: viewModel)

            #expect(viewModel.networkAssignments == [assignment])
            #expect(viewModel.rollHistory.count == 1)
            #expect(viewModel.rollHistory[0].name == "Test Blade")
            #expect(viewModel.hasNewRollHistory)
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
}
