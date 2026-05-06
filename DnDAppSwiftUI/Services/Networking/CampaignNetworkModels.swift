import Foundation

// MARK: - Role & Connection State

nonisolated enum CampaignNetworkRole: String, Codable, Sendable {
    case host
    case client
}

nonisolated enum CampaignConnectionState: Equatable, Sendable {
    case idle
    case browsing
    case hosting(port: UInt16?)
    case connecting
    case connectedUnsynced(peerName: String)
    case syncing(peerName: String)
    case ready(peerName: String)
    case stale(peerName: String)
    case failed(String)

    var peerName: String? {
        switch self {
        case .connectedUnsynced(let peerName),
             .syncing(let peerName),
             .ready(let peerName),
             .stale(let peerName):
            return peerName
        default:
            return nil
        }
    }
}

// MARK: - Peer

nonisolated struct CampaignPeer: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let endpointDescription: String
}

// MARK: - Envelope & Messages

nonisolated struct CampaignNetworkEnvelope: Codable, Sendable {
    static let currentSchemaVersion = 2
    static let preSessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    let schemaVersion: Int
    let sessionID: UUID
    let sentAt: Date
    let message: CampaignNetworkMessage

    init(sessionID: UUID, message: CampaignNetworkMessage) {
        self.schemaVersion = Self.currentSchemaVersion
        self.sessionID = sessionID
        self.sentAt = Date()
        self.message = message
    }
}

nonisolated enum CampaignNetworkMessage: Codable, Sendable {
    case hello(Hello)
    case welcome(CampaignNetworkWelcome)
    case resumeSession(CampaignResumeSession)
    case snapshot(CampaignNetworkSnapshot)
    case delta(CampaignDelta)
    case deltaBatch(CampaignDeltaBatch)
    case requestSnapshot
    case assignmentChanged(PlayerAssignment)
    case command(CampaignCommandEnvelope)
    case commandAccepted(CampaignCommandAccepted)
    case commandRejected(CampaignCommandRejected)
    case ping(UUID)
    case pong(UUID)
    case error(CampaignErrorMessage)

    // MARK: - Hello

    struct Hello: Codable, Equatable, Sendable {
        let clientID: UUID
        let displayName: String
        let protocolVersion: Int
        let capabilities: CampaignClientCapabilities?

        init(
            clientID: UUID,
            displayName: String,
            protocolVersion: Int = CampaignNetworkEnvelope.currentSchemaVersion,
            capabilities: CampaignClientCapabilities? = .default
        ) {
            self.clientID = clientID
            self.displayName = displayName
            self.protocolVersion = protocolVersion
            self.capabilities = capabilities
        }
    }

    // MARK: - Custom Codable

    private enum CaseKey: String, Codable {
        case hello, welcome, resumeSession, snapshot, delta, deltaBatch, requestSnapshot
        case assignmentChanged, command, commandAccepted, commandRejected
        case ping, pong, error
    }

    private enum CodingKeys: String, CodingKey {
        case type, payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .hello(let v):
            try container.encode(CaseKey.hello, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .welcome(let v):
            try container.encode(CaseKey.welcome, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .resumeSession(let v):
            try container.encode(CaseKey.resumeSession, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .snapshot(let v):
            try container.encode(CaseKey.snapshot, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .delta(let v):
            try container.encode(CaseKey.delta, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .deltaBatch(let v):
            try container.encode(CaseKey.deltaBatch, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .requestSnapshot:
            try container.encode(CaseKey.requestSnapshot, forKey: .type)
        case .assignmentChanged(let v):
            try container.encode(CaseKey.assignmentChanged, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .command(let v):
            try container.encode(CaseKey.command, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .commandAccepted(let v):
            try container.encode(CaseKey.commandAccepted, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .commandRejected(let v):
            try container.encode(CaseKey.commandRejected, forKey: .type)
            try container.encode(v, forKey: .payload)
        case .ping(let id):
            try container.encode(CaseKey.ping, forKey: .type)
            try container.encode(id, forKey: .payload)
        case .pong(let id):
            try container.encode(CaseKey.pong, forKey: .type)
            try container.encode(id, forKey: .payload)
        case .error(let msg):
            try container.encode(CaseKey.error, forKey: .type)
            try container.encode(msg, forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CaseKey.self, forKey: .type)
        switch type {
        case .hello:
            self = .hello(try container.decode(Hello.self, forKey: .payload))
        case .welcome:
            self = .welcome(try container.decode(CampaignNetworkWelcome.self, forKey: .payload))
        case .resumeSession:
            self = .resumeSession(try container.decode(CampaignResumeSession.self, forKey: .payload))
        case .snapshot:
            self = .snapshot(try container.decode(CampaignNetworkSnapshot.self, forKey: .payload))
        case .delta:
            self = .delta(try container.decode(CampaignDelta.self, forKey: .payload))
        case .deltaBatch:
            self = .deltaBatch(try container.decode(CampaignDeltaBatch.self, forKey: .payload))
        case .requestSnapshot:
            self = .requestSnapshot
        case .assignmentChanged:
            self = .assignmentChanged(try container.decode(PlayerAssignment.self, forKey: .payload))
        case .command:
            self = .command(try container.decode(CampaignCommandEnvelope.self, forKey: .payload))
        case .commandAccepted:
            self = .commandAccepted(try container.decode(CampaignCommandAccepted.self, forKey: .payload))
        case .commandRejected:
            self = .commandRejected(try container.decode(CampaignCommandRejected.self, forKey: .payload))
        case .ping:
            self = .ping(try container.decode(UUID.self, forKey: .payload))
        case .pong:
            self = .pong(try container.decode(UUID.self, forKey: .payload))
        case .error:
            self = .error(try container.decode(CampaignErrorMessage.self, forKey: .payload))
        }
    }
}

nonisolated struct CampaignClientCapabilities: Codable, Equatable, Sendable {
    let supportsDeltaBatch: Bool
    let supportsResume: Bool

    static let `default` = CampaignClientCapabilities(
        supportsDeltaBatch: true,
        supportsResume: true
    )
}

nonisolated struct CampaignNetworkWelcome: Codable, Equatable, Sendable {
    let sessionID: UUID
    let sessionName: String
    let protocolVersion: Int
    let currentRevision: Int
    let heartbeatIntervalMs: Int
    let deltaRetentionLimit: Int
}

nonisolated struct CampaignResumeSession: Codable, Equatable, Sendable {
    let clientID: UUID
    let lastAppliedRevision: Int
}

// MARK: - Player Assignment

nonisolated struct PlayerAssignment: Codable, Equatable, Sendable {
    let clientID: UUID
    let playerCharacterID: UUID
    let assignedByHostAt: Date
}

// MARK: - Commands

nonisolated struct CampaignCommandEnvelope: Codable, Equatable, Sendable {
    let commandID: UUID
    let clientID: UUID
    let baseRevision: Int
    let command: PlayerCharacterUpdateCommand

    init(clientID: UUID, baseRevision: Int, command: PlayerCharacterUpdateCommand) {
        self.commandID = UUID()
        self.clientID = clientID
        self.baseRevision = baseRevision
        self.command = command
    }

    init(commandID: UUID, clientID: UUID, baseRevision: Int, command: PlayerCharacterUpdateCommand) {
        self.commandID = commandID
        self.clientID = clientID
        self.baseRevision = baseRevision
        self.command = command
    }
}

nonisolated enum PlayerCharacterUpdateCommand: Codable, Equatable, Sendable {
    case setHitPoints(playerID: UUID, currentHP: Int, temporaryHP: Int)
    case setStatuses(playerID: UUID, statuses: [NetworkStatusCondition])
    case setSpellSlot(playerID: UUID, level: Int, available: Int)
    case setActionUses(playerID: UUID, actionIndex: Int, remainingUses: Int?)
    case setInventoryEquipped(playerID: UUID, inventoryItemID: UUID, isEquipped: Bool)
    case submitRoll(playerID: UUID, roll: NetworkRollEntry)

    var playerID: UUID {
        switch self {
        case .setHitPoints(let id, _, _): return id
        case .setStatuses(let id, _): return id
        case .setSpellSlot(let id, _, _): return id
        case .setActionUses(let id, _, _): return id
        case .setInventoryEquipped(let id, _, _): return id
        case .submitRoll(let id, _): return id
        }
    }

    // MARK: - Custom Codable

    private enum CaseKey: String, Codable {
        case setHitPoints, setStatuses, setSpellSlot
        case setActionUses, setInventoryEquipped, submitRoll
    }

    private enum CodingKeys: String, CodingKey {
        case type, playerID
        case currentHP, temporaryHP
        case statuses
        case level, available
        case actionIndex, remainingUses
        case inventoryItemID, isEquipped
        case roll
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .setHitPoints(let pid, let hp, let thp):
            try c.encode(CaseKey.setHitPoints, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(hp, forKey: .currentHP)
            try c.encode(thp, forKey: .temporaryHP)
        case .setStatuses(let pid, let s):
            try c.encode(CaseKey.setStatuses, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(s, forKey: .statuses)
        case .setSpellSlot(let pid, let lvl, let avail):
            try c.encode(CaseKey.setSpellSlot, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(lvl, forKey: .level)
            try c.encode(avail, forKey: .available)
        case .setActionUses(let pid, let idx, let rem):
            try c.encode(CaseKey.setActionUses, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(idx, forKey: .actionIndex)
            try c.encode(rem, forKey: .remainingUses)
        case .setInventoryEquipped(let pid, let iid, let eq):
            try c.encode(CaseKey.setInventoryEquipped, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(iid, forKey: .inventoryItemID)
            try c.encode(eq, forKey: .isEquipped)
        case .submitRoll(let pid, let r):
            try c.encode(CaseKey.submitRoll, forKey: .type)
            try c.encode(pid, forKey: .playerID)
            try c.encode(r, forKey: .roll)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(CaseKey.self, forKey: .type)
        switch type {
        case .setHitPoints:
            self = .setHitPoints(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                currentHP: try c.decode(Int.self, forKey: .currentHP),
                temporaryHP: try c.decode(Int.self, forKey: .temporaryHP))
        case .setStatuses:
            self = .setStatuses(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                statuses: try c.decode([NetworkStatusCondition].self, forKey: .statuses))
        case .setSpellSlot:
            self = .setSpellSlot(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                level: try c.decode(Int.self, forKey: .level),
                available: try c.decode(Int.self, forKey: .available))
        case .setActionUses:
            self = .setActionUses(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                actionIndex: try c.decode(Int.self, forKey: .actionIndex),
                remainingUses: try c.decodeIfPresent(Int.self, forKey: .remainingUses))
        case .setInventoryEquipped:
            self = .setInventoryEquipped(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                inventoryItemID: try c.decode(UUID.self, forKey: .inventoryItemID),
                isEquipped: try c.decode(Bool.self, forKey: .isEquipped))
        case .submitRoll:
            self = .submitRoll(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                roll: try c.decode(NetworkRollEntry.self, forKey: .roll))
        }
    }
}

// MARK: - Command Receipts

nonisolated struct CampaignCommandAccepted: Codable, Equatable, Sendable {
    let commandID: UUID
    let appliedRevision: Int
    let appliedAt: Date
}

nonisolated struct CampaignCommandRejected: Codable, Equatable, Sendable {
    let commandID: UUID
    let rejectedAt: Date
    let code: String
    let reason: String
}

nonisolated struct CampaignErrorMessage: Codable, Equatable, Sendable {
    let code: String
    let message: String
}

// MARK: - Deltas

nonisolated struct CampaignDelta: Codable, Equatable, Sendable {
    let deltaID: UUID
    let revision: Int
    let previousRevision: Int
    let createdAt: Date
    let originClientID: UUID?
    let changes: [CampaignDeltaChange]
}

nonisolated struct CampaignDeltaBatch: Codable, Equatable, Sendable {
    let fromRevision: Int
    let toRevision: Int
    let deltas: [CampaignDelta]
}

nonisolated enum CampaignDeltaChange: Codable, Equatable, Sendable {
    case assignmentChanged(PlayerAssignment)
    case playerHitPointsChanged(playerID: UUID, currentHP: Int, temporaryHP: Int)
    case playerStatusesChanged(playerID: UUID, statuses: [NetworkStatusCondition])
    case playerSpellSlotChanged(playerID: UUID, level: Int, available: Int)
    case playerActionUsesChanged(playerID: UUID, actionIndex: Int, remainingUses: Int?)
    case playerInventoryItemEquippedChanged(playerID: UUID, inventoryItemID: UUID, isEquipped: Bool)
    case combatentHitPointsChanged(combatentID: UUID, currentHP: Int, temporaryHP: Int)
    case combatentStatusesChanged(combatentID: UUID, statuses: [NetworkStatusCondition])
    case combatentSpellSlotChanged(combatentID: UUID, level: Int, available: Int)
    case rollInserted(entry: NetworkRollEntry, position: String)

    private enum CaseKey: String, Codable {
        case assignmentChanged
        case playerHitPointsChanged
        case playerStatusesChanged
        case playerSpellSlotChanged
        case playerActionUsesChanged
        case playerInventoryItemEquippedChanged
        case combatentHitPointsChanged
        case combatentStatusesChanged
        case combatentSpellSlotChanged
        case rollInserted
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case assignment
        case playerID, combatentID
        case currentHP, temporaryHP
        case statuses
        case level, available
        case actionIndex, remainingUses
        case inventoryItemID, isEquipped
        case entry, position
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .assignmentChanged(let assignment):
            try c.encode(CaseKey.assignmentChanged, forKey: .type)
            try c.encode(assignment, forKey: .assignment)
        case .playerHitPointsChanged(let playerID, let currentHP, let temporaryHP):
            try c.encode(CaseKey.playerHitPointsChanged, forKey: .type)
            try c.encode(playerID, forKey: .playerID)
            try c.encode(currentHP, forKey: .currentHP)
            try c.encode(temporaryHP, forKey: .temporaryHP)
        case .playerStatusesChanged(let playerID, let statuses):
            try c.encode(CaseKey.playerStatusesChanged, forKey: .type)
            try c.encode(playerID, forKey: .playerID)
            try c.encode(statuses, forKey: .statuses)
        case .playerSpellSlotChanged(let playerID, let level, let available):
            try c.encode(CaseKey.playerSpellSlotChanged, forKey: .type)
            try c.encode(playerID, forKey: .playerID)
            try c.encode(level, forKey: .level)
            try c.encode(available, forKey: .available)
        case .playerActionUsesChanged(let playerID, let actionIndex, let remainingUses):
            try c.encode(CaseKey.playerActionUsesChanged, forKey: .type)
            try c.encode(playerID, forKey: .playerID)
            try c.encode(actionIndex, forKey: .actionIndex)
            try c.encodeIfPresent(remainingUses, forKey: .remainingUses)
        case .playerInventoryItemEquippedChanged(let playerID, let inventoryItemID, let isEquipped):
            try c.encode(CaseKey.playerInventoryItemEquippedChanged, forKey: .type)
            try c.encode(playerID, forKey: .playerID)
            try c.encode(inventoryItemID, forKey: .inventoryItemID)
            try c.encode(isEquipped, forKey: .isEquipped)
        case .combatentHitPointsChanged(let combatentID, let currentHP, let temporaryHP):
            try c.encode(CaseKey.combatentHitPointsChanged, forKey: .type)
            try c.encode(combatentID, forKey: .combatentID)
            try c.encode(currentHP, forKey: .currentHP)
            try c.encode(temporaryHP, forKey: .temporaryHP)
        case .combatentStatusesChanged(let combatentID, let statuses):
            try c.encode(CaseKey.combatentStatusesChanged, forKey: .type)
            try c.encode(combatentID, forKey: .combatentID)
            try c.encode(statuses, forKey: .statuses)
        case .combatentSpellSlotChanged(let combatentID, let level, let available):
            try c.encode(CaseKey.combatentSpellSlotChanged, forKey: .type)
            try c.encode(combatentID, forKey: .combatentID)
            try c.encode(level, forKey: .level)
            try c.encode(available, forKey: .available)
        case .rollInserted(let entry, let position):
            try c.encode(CaseKey.rollInserted, forKey: .type)
            try c.encode(entry, forKey: .entry)
            try c.encode(position, forKey: .position)
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(CaseKey.self, forKey: .type)
        switch type {
        case .assignmentChanged:
            self = .assignmentChanged(try c.decode(PlayerAssignment.self, forKey: .assignment))
        case .playerHitPointsChanged:
            self = .playerHitPointsChanged(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                currentHP: try c.decode(Int.self, forKey: .currentHP),
                temporaryHP: try c.decode(Int.self, forKey: .temporaryHP))
        case .playerStatusesChanged:
            self = .playerStatusesChanged(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                statuses: try c.decode([NetworkStatusCondition].self, forKey: .statuses))
        case .playerSpellSlotChanged:
            self = .playerSpellSlotChanged(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                level: try c.decode(Int.self, forKey: .level),
                available: try c.decode(Int.self, forKey: .available))
        case .playerActionUsesChanged:
            self = .playerActionUsesChanged(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                actionIndex: try c.decode(Int.self, forKey: .actionIndex),
                remainingUses: try c.decodeIfPresent(Int.self, forKey: .remainingUses))
        case .playerInventoryItemEquippedChanged:
            self = .playerInventoryItemEquippedChanged(
                playerID: try c.decode(UUID.self, forKey: .playerID),
                inventoryItemID: try c.decode(UUID.self, forKey: .inventoryItemID),
                isEquipped: try c.decode(Bool.self, forKey: .isEquipped))
        case .combatentHitPointsChanged:
            self = .combatentHitPointsChanged(
                combatentID: try c.decode(UUID.self, forKey: .combatentID),
                currentHP: try c.decode(Int.self, forKey: .currentHP),
                temporaryHP: try c.decode(Int.self, forKey: .temporaryHP))
        case .combatentStatusesChanged:
            self = .combatentStatusesChanged(
                combatentID: try c.decode(UUID.self, forKey: .combatentID),
                statuses: try c.decode([NetworkStatusCondition].self, forKey: .statuses))
        case .combatentSpellSlotChanged:
            self = .combatentSpellSlotChanged(
                combatentID: try c.decode(UUID.self, forKey: .combatentID),
                level: try c.decode(Int.self, forKey: .level),
                available: try c.decode(Int.self, forKey: .available))
        case .rollInserted:
            self = .rollInserted(
                entry: try c.decode(NetworkRollEntry.self, forKey: .entry),
                position: try c.decode(String.self, forKey: .position))
        }
    }
}

// MARK: - Network DTOs

nonisolated struct NetworkStatusCondition: Codable, Equatable, Sendable {
    let name: String
    let effect: String
    let desc: String

    init(name: String, effect: String, desc: String) {
        self.name = name
        self.effect = effect
        self.desc = desc
    }

    init(from status: StatusCondition) {
        self.name = status.name
        self.effect = status.effect
        self.desc = status.desc
    }

    func toStatusCondition() -> StatusCondition {
        StatusCondition(name: name, effect: effect, desc: desc)
    }
}

nonisolated struct NetworkRollEntry: Codable, Equatable, Sendable {
    let type: String
    let name: String
    let roll: Int
    let modifier: Int
    let total: Double
    let timestamp: Date

    init(from entry: RollEntry) {
        self.type = entry.type
        self.name = entry.name
        self.roll = entry.roll
        self.modifier = entry.modifier
        self.total = entry.total
        self.timestamp = entry.timestamp
    }

    func toRollEntry() -> RollEntry {
        RollEntry(type: type, name: name, roll: roll, modifier: modifier, total: total, timestamp: timestamp)
    }
}

nonisolated struct NetworkSpellSlot: Codable, Equatable, Sendable {
    let level: Int
    let max: Int
    let available: Int

    init(level: Int, max: Int, available: Int) {
        self.level = level
        self.max = max
        self.available = available
    }

    init(from slot: SpellSlot) {
        self.level = slot.level
        self.max = slot.max
        self.available = slot.available
    }

    func toSpellSlot() -> SpellSlot {
        SpellSlot(level: level, max: max, available: available)
    }
}

nonisolated struct NetworkAttack: Codable, Equatable, Sendable {
    let id: UUID
    let name: String
    let hitBonus: Int
    let reach: String
    let damageRoll: String
    let damageType: String
    let saveDC: Int?
    let description: String?
    let maxUses: Int?
    let remainingUses: Int?

    init(id: UUID, name: String, hitBonus: Int, reach: String, damageRoll: String, damageType: String, saveDC: Int?, description: String?, maxUses: Int?, remainingUses: Int?) {
        self.id = id
        self.name = name
        self.hitBonus = hitBonus
        self.reach = reach
        self.damageRoll = damageRoll
        self.damageType = damageType
        self.saveDC = saveDC
        self.description = description
        self.maxUses = maxUses
        self.remainingUses = remainingUses
    }

    init(from attack: Attack) {
        self.id = attack.id
        self.name = attack.name
        self.hitBonus = attack.hitBonus
        self.reach = attack.reach
        self.damageRoll = attack.damageRoll
        self.damageType = attack.damageType.rawValue
        self.saveDC = attack.saveDC
        self.description = attack.description
        self.maxUses = attack.maxUses
        self.remainingUses = attack.remainingUses
    }

    func toAttack() -> Attack {
        Attack(
            id: id, name: name, hitBonus: hitBonus, reach: reach,
            damageRoll: damageRoll,
            damageType: DamageType(rawValue: damageType) ?? .bludgeoning,
            saveDC: saveDC, description: description,
            maxUses: maxUses, remainingUses: remainingUses)
    }
}

nonisolated struct NetworkCombatent: Codable, Equatable, Sendable {
    let id: UUID
    let name: String
    let currentHP: Int
    let maxHP: Int
    let temporaryHP: Int
    let initiative: Double
    let isTurn: Bool
    let status: [NetworkStatusCondition]?
    let creatureType: String?
    let spellSlots: [NetworkSpellSlot]
    let speed: NetworkMovementSpeed
    let sourceSidebarID: String?
    let sourceEntityID: UUID?
    let sourceEntityType: String?
    let isLairAction: Bool

    init(id: UUID, name: String, currentHP: Int, maxHP: Int, temporaryHP: Int, initiative: Double, isTurn: Bool, status: [NetworkStatusCondition]?, creatureType: String?, spellSlots: [NetworkSpellSlot], speed: NetworkMovementSpeed, sourceSidebarID: String?, sourceEntityID: UUID?, sourceEntityType: String?, isLairAction: Bool) {
        self.id = id
        self.name = name
        self.currentHP = currentHP
        self.maxHP = maxHP
        self.temporaryHP = temporaryHP
        self.initiative = initiative
        self.isTurn = isTurn
        self.status = status
        self.creatureType = creatureType
        self.spellSlots = spellSlots
        self.speed = speed
        self.sourceSidebarID = sourceSidebarID
        self.sourceEntityID = sourceEntityID
        self.sourceEntityType = sourceEntityType
        self.isLairAction = isLairAction
    }

    init(from c: Combatent) {
        self.id = c.id
        self.name = c.name
        self.currentHP = c.currentHP
        self.maxHP = c.maxHP
        self.temporaryHP = c.temporaryHP
        self.initiative = c.initiative
        self.isTurn = c.isTurn
        self.status = c.status.map { $0.map { NetworkStatusCondition(from: $0) } }
        self.creatureType = c.creatureType
        self.spellSlots = c.spellSlots.map { NetworkSpellSlot(from: $0) }
        self.speed = NetworkMovementSpeed(from: c.speed)
        self.sourceSidebarID = c.sourceSidebarID
        self.sourceEntityID = c.sourceEntityID
        self.sourceEntityType = c.sourceEntityType?.rawValue
        self.isLairAction = c.isLairAction
    }

    func toCombatent() -> Combatent {
        Combatent(
            id: id, name: name, currentHP: currentHP, maxHP: maxHP,
            temporaryHP: temporaryHP, initiative: initiative, isTurn: isTurn,
            status: status.map { $0.map { $0.toStatusCondition() } },
            creatureType: creatureType,
            spellSlots: spellSlots.map { $0.toSpellSlot() },
            speed: speed.toMovementSpeed(),
            sourceSidebarID: sourceSidebarID,
            sourceEntityID: sourceEntityID,
            sourceEntityType: sourceEntityType.flatMap { CombatentEntityType(rawValue: $0) },
            isLairAction: isLairAction)
    }
}

nonisolated struct NetworkMovementSpeed: Codable, Equatable, Sendable {
    let walk: Int
    let swim: Int?
    let fly: Int?
    let climb: Int?
    let burrow: Int?
    let hover: Bool

    init(walk: Int, swim: Int? = nil, fly: Int? = nil, climb: Int? = nil, burrow: Int? = nil, hover: Bool = false) {
        self.walk = walk
        self.swim = swim
        self.fly = fly
        self.climb = climb
        self.burrow = burrow
        self.hover = hover
    }

    init(from s: MovementSpeed) {
        self.walk = s.walk
        self.swim = s.swim
        self.fly = s.fly
        self.climb = s.climb
        self.burrow = s.burrow
        self.hover = s.hover
    }

    func toMovementSpeed() -> MovementSpeed {
        MovementSpeed(walk: walk, swim: swim, fly: fly, climb: climb, burrow: burrow, hover: hover)
    }
}

nonisolated struct NetworkInventoryItem: Codable, Equatable, Sendable {
    let id: UUID
    let lootItemID: String
    let isEquipped: Bool

    init(id: UUID, lootItemID: String, isEquipped: Bool) {
        self.id = id
        self.lootItemID = lootItemID
        self.isEquipped = isEquipped
    }

    init(from item: InventoryItem) {
        self.id = item.id
        self.lootItemID = item.lootItemID
        self.isEquipped = item.isEquipped
    }

    func toInventoryItem() -> InventoryItem {
        InventoryItem(id: id, lootItemID: lootItemID, isEquipped: isEquipped)
    }
}

nonisolated struct NetworkAbilityScores: Codable, Equatable, Sendable {
    let strength: Int
    let dexterity: Int
    let constitution: Int
    let intelligence: Int
    let wisdom: Int
    let charisma: Int

    init(from s: AbilityScores) {
        self.strength = s.strength
        self.dexterity = s.dexterity
        self.constitution = s.constitution
        self.intelligence = s.intelligence
        self.wisdom = s.wisdom
        self.charisma = s.charisma
    }

    func toAbilityScores() -> AbilityScores {
        AbilityScores(
            strength: strength, dexterity: dexterity, constitution: constitution,
            intelligence: intelligence, wisdom: wisdom, charisma: charisma)
    }
}

nonisolated struct NetworkPlayerState: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let currentHP: Int
    let maxHP: Int
    let abilityScores: NetworkAbilityScores
    let status: [NetworkStatusCondition]?
    let spellSlots: [NetworkSpellSlot]
    let actions: [NetworkAttack]
    let initiative: Double

    init(id: String, name: String, currentHP: Int, maxHP: Int, abilityScores: NetworkAbilityScores, status: [NetworkStatusCondition]?, spellSlots: [NetworkSpellSlot], actions: [NetworkAttack], initiative: Double) {
        self.id = id
        self.name = name
        self.currentHP = currentHP
        self.maxHP = maxHP
        self.abilityScores = abilityScores
        self.status = status
        self.spellSlots = spellSlots
        self.actions = actions
        self.initiative = initiative
    }

    init(from p: PlayerCharacter) {
        self.id = p.id.uuidString
        self.name = p.name
        self.currentHP = p.currentHP
        self.maxHP = p.maxHP
        self.abilityScores = NetworkAbilityScores(from: p.abilityScores)
        self.status = p.status.map { $0.map { NetworkStatusCondition(from: $0) } }
        self.spellSlots = p.spellSlots.map { NetworkSpellSlot(from: $0) }
        self.actions = p.actions.map { NetworkAttack(from: $0) }
        self.initiative = p.initiative
    }
}

nonisolated struct NetworkMonsterState: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let currentHP: Int
    let maxHP: Int
    let abilityScores: NetworkAbilityScores
    let status: [NetworkStatusCondition]?
    let actions: [NetworkAttack]
    let initiative: Double

    init(id: String, name: String, currentHP: Int, maxHP: Int, abilityScores: NetworkAbilityScores, status: [NetworkStatusCondition]?, actions: [NetworkAttack], initiative: Double) {
        self.id = id
        self.name = name
        self.currentHP = currentHP
        self.maxHP = maxHP
        self.abilityScores = abilityScores
        self.status = status
        self.actions = actions
        self.initiative = initiative
    }

    init(from m: Monster) {
        self.id = m.id.uuidString
        self.name = m.name
        self.currentHP = m.currentHP
        self.maxHP = m.maxHP
        self.abilityScores = NetworkAbilityScores(from: m.abilityScores)
        self.status = m.status.map { $0.map { NetworkStatusCondition(from: $0) } }
        self.actions = m.actions.map { NetworkAttack(from: $0) }
        self.initiative = m.initiative
    }
}

nonisolated struct NetworkNPCState: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let currentHP: Int
    let maxHP: Int
    let abilityScores: NetworkAbilityScores
    let status: [NetworkStatusCondition]?
    let spellSlots: [NetworkSpellSlot]
    let actions: [NetworkAttack]
    let initiative: Double

    init(id: String, name: String, currentHP: Int, maxHP: Int, abilityScores: NetworkAbilityScores, status: [NetworkStatusCondition]?, spellSlots: [NetworkSpellSlot], actions: [NetworkAttack], initiative: Double) {
        self.id = id
        self.name = name
        self.currentHP = currentHP
        self.maxHP = maxHP
        self.abilityScores = abilityScores
        self.status = status
        self.spellSlots = spellSlots
        self.actions = actions
        self.initiative = initiative
    }

    init(from n: NPC) {
        self.id = n.id.uuidString
        self.name = n.name
        self.currentHP = n.currentHP
        self.maxHP = n.maxHP
        self.abilityScores = NetworkAbilityScores(from: n.abilityScores)
        self.status = n.status.map { $0.map { NetworkStatusCondition(from: $0) } }
        self.spellSlots = n.spellSlots.map { NetworkSpellSlot(from: $0) }
        self.actions = n.actions.map { NetworkAttack(from: $0) }
        self.initiative = n.initiative
    }
}

// MARK: - Wiki/Loot/Spell/Asset/Encounter DTOs

nonisolated struct NetworkWikiEntry: Codable, Equatable, Sendable {
    let id: String
    let title: String
    let description: String
    let aliases: [String]

    init(from e: WikiEntry) {
        self.id = e.id; self.title = e.title
        self.description = e.description; self.aliases = e.aliases
    }

    func toWikiEntry() -> WikiEntry {
        WikiEntry(id: id, title: title, description: description, aliases: aliases)
    }
}

nonisolated struct NetworkLootItem: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let type: String
    let rarity: String
    let description: String
    let value: String?
    let requiresAttunement: Bool
    let properties: [String]
    let modifiers: [NetworkItemModifier]

    init(from item: LootItem) {
        self.id = item.id; self.name = item.name
        self.type = item.type; self.rarity = item.rarity
        self.description = item.description; self.value = item.value
        self.requiresAttunement = item.requiresAttunement
        self.properties = item.properties
        self.modifiers = item.modifiers.map { NetworkItemModifier(from: $0) }
    }

    func toLootItem() -> LootItem {
        LootItem(
            id: id, name: name, type: type, rarity: rarity,
            description: description, value: value,
            requiresAttunement: requiresAttunement,
            properties: properties,
            modifiers: modifiers.map { $0.toItemModifier() })
    }
}

nonisolated struct NetworkItemModifier: Codable, Equatable, Sendable {
    let kind: String
    let value: Int
    let ability: String?

    init(from m: ItemModifier) {
        switch m {
        case .acBonus(let v): self.kind = "acBonus"; self.value = v; self.ability = nil
        case .savingThrowBonus(let v): self.kind = "savingThrowBonus"; self.value = v; self.ability = nil
        case .attackBonus(let v): self.kind = "attackBonus"; self.value = v; self.ability = nil
        case .damageBonus(let v): self.kind = "damageBonus"; self.value = v; self.ability = nil
        case .setAbilityScore(let a, let v): self.kind = "setAbilityScore"; self.value = v; self.ability = a
        }
    }

    func toItemModifier() -> ItemModifier {
        switch kind {
        case "acBonus": return .acBonus(value)
        case "savingThrowBonus": return .savingThrowBonus(value)
        case "attackBonus": return .attackBonus(value)
        case "damageBonus": return .damageBonus(value)
        case "setAbilityScore": return .setAbilityScore(ability ?? "STR", value)
        default: return .acBonus(value)
        }
    }
}

nonisolated struct NetworkSpellEntry: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let level: Int
    let school: String
    let castingTime: String
    let range: String
    let components: String
    let duration: String
    let description: String
    let concentration: Bool
    let ritual: Bool
    let damageRoll: String?
    let damageType: String?
    let saveDC: Int?

    init(from s: SpellEntry) {
        self.id = s.id; self.name = s.name; self.level = s.level
        self.school = s.school; self.castingTime = s.castingTime
        self.range = s.range; self.components = s.components
        self.duration = s.duration; self.description = s.description
        self.concentration = s.concentration; self.ritual = s.ritual
        self.damageRoll = s.damageRoll
        self.damageType = s.damageType?.rawValue
        self.saveDC = s.saveDC
    }

    func toSpellEntry() -> SpellEntry {
        SpellEntry(
            id: id, name: name, level: level, school: school,
            castingTime: castingTime, range: range, components: components,
            duration: duration, description: description,
            concentration: concentration, ritual: ritual,
            damageRoll: damageRoll,
            damageType: damageType.flatMap { DamageType(rawValue: $0) },
            saveDC: saveDC)
    }
}

nonisolated struct NetworkAsset: Codable, Equatable, Sendable {
    let id: String
    let name: String
    let type: String
    let description: String
    let isPublic: Bool
    let location: String?
    let difficulty: String?
    let rewards: String?

    init(from a: Asset) {
        self.id = a.id; self.name = a.name
        self.type = a.type.rawValue; self.description = a.description
        self.isPublic = a.isPublic; self.location = a.location
        self.difficulty = a.difficulty; self.rewards = a.rewards
    }

    func toAsset() -> Asset {
        Asset(
            id: id, name: name,
            type: AssetType(rawValue: type) ?? .location,
            description: description, isPublic: isPublic,
            location: location, difficulty: difficulty, rewards: rewards)
    }
}

nonisolated struct NetworkEncounter: Codable, Equatable, Sendable {
    let id: UUID
    let name: String
    let memberSidebarIDs: [String]

    init(from e: Encounter) {
        self.id = e.id; self.name = e.name
        self.memberSidebarIDs = e.memberSidebarIDs
    }

    func toEncounter() -> Encounter {
        Encounter(id: id, name: name, memberSidebarIDs: memberSidebarIDs)
    }
}
