import Foundation
import Network
import Observation

/// Manages Bonjour-based local network hosting, discovery, and connections.
///
/// - Host mode: `NWListener` accepts multiple client TCP connections.
/// - Client mode: `NWBrowser` discovers hosts, `NWConnection` connects to one.
///
/// All observable state is published on the main actor; network I/O runs on a
/// dedicated dispatch queue.
@Observable
@MainActor
final class CampaignNetworkingService {

    // MARK: - Public Observable State

    private(set) var role: CampaignNetworkRole?
    private(set) var connectionState: CampaignConnectionState = .idle
    private(set) var discoveredPeers: [CampaignPeer] = []
    private(set) var connectedClientCount: Int = 0
    var lastError: String?

    /// Host-side: connected client info keyed by internal connection ID.
    var connectedClients: [UUID: ConnectedClient] = [:]

    struct ConnectedClient: Identifiable, Equatable, Sendable {
        let id: UUID
        let displayName: String
        var assignedPlayerID: UUID?
    }

    // MARK: - Private State

    @ObservationIgnored private let networkQueue = DispatchQueue(label: "com.dndapp.network", qos: .userInitiated)
    @ObservationIgnored private let bonjourType = "_dndapp._tcp"

    @ObservationIgnored private var listener: NWListener?
    @ObservationIgnored private var browser: NWBrowser?
    @ObservationIgnored private var clientConnection: NWConnection?

    // Host-side connections keyed by connection ID
    @ObservationIgnored private var hostConnections: [UUID: NWConnection] = [:]
    @ObservationIgnored private var connectionIDMap: [ObjectIdentifier: UUID] = [:]

    // Client-side identity
    @ObservationIgnored private(set) var clientID: UUID = UUID()

    // Browser endpoint → peer mapping
    @ObservationIgnored private var endpointPeerMap: [NWEndpoint: CampaignPeer] = [:]

    // Framing parsers per connection
    @ObservationIgnored private var parsers: [UUID: CampaignNetworkFraming.Parser] = [:]
    @ObservationIgnored private var clientParser = CampaignNetworkFraming.Parser()

    // Session
    @ObservationIgnored var sessionID: UUID?
    @ObservationIgnored var sessionName: String = ""
    @ObservationIgnored var currentRevision: Int = 0
    @ObservationIgnored var lastAppliedRevision: Int = 0
    @ObservationIgnored private var deltaLog: [CampaignDelta] = []
    @ObservationIgnored private let maxDeltaLogCount = 500
    @ObservationIgnored private var commandReceipts: [UUID: [UUID: CampaignCommandResult]] = [:]
    @ObservationIgnored private var connectedPeerName: String?

    // Callbacks
    @ObservationIgnored private var onMessageReceived: ((CampaignNetworkEnvelope, UUID?) -> Void)?

    // JSON coders
    @ObservationIgnored private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .millisecondsSince1970
        return e
    }()
    @ObservationIgnored private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .millisecondsSince1970
        return d
    }()

    struct CampaignCommandResult: Sendable {
        let accepted: CampaignCommandAccepted?
        let rejected: CampaignCommandRejected?
    }

    // MARK: - Host API

    /// Start hosting a campaign session. Listens on a random TCP port, advertised via Bonjour.
    func startHosting(
        sessionID: UUID = UUID(),
        sessionName: String,
        onMessage: @escaping @Sendable (CampaignNetworkEnvelope, UUID?) -> Void
    ) {
        stop()
        self.role = .host
        self.sessionID = sessionID
        self.sessionName = sessionName
        self.currentRevision = 0
        self.lastAppliedRevision = 0
        self.deltaLog.removeAll()
        self.commandReceipts.removeAll()
        self.onMessageReceived = onMessage

        do {
            let params = NWParameters.tcp
            params.includePeerToPeer = true
            let listener = try NWListener(using: params)
            listener.service = NWListener.Service(name: sessionName, type: bonjourType)

            listener.stateUpdateHandler = { [weak self] state in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    switch state {
                    case .ready:
                        let port = listener.port?.rawValue
                        self.connectionState = .hosting(port: port)
                        self.lastError = nil
                    case .failed(let error):
                        self.connectionState = .failed(error.localizedDescription)
                        self.lastError = error.localizedDescription
                    case .cancelled:
                        self.connectionState = .idle
                    default:
                        break
                    }
                }
            }

            listener.newConnectionHandler = { [weak self] connection in
                Task { @MainActor [weak self] in
                    self?.handleNewHostConnection(connection)
                }
            }

            self.listener = listener
            listener.start(queue: networkQueue)
            connectionState = .hosting(port: nil)
        } catch {
            connectionState = .failed(error.localizedDescription)
            lastError = error.localizedDescription
        }
    }

    // MARK: - Browse API

    /// Start browsing for campaign sessions on the local network.
    func startBrowsing(
        onMessage: @escaping @Sendable (CampaignNetworkEnvelope, UUID?) -> Void
    ) {
        stop()
        self.role = .client
        self.onMessageReceived = onMessage

        let params = NWParameters()
        params.includePeerToPeer = true
        let browser = NWBrowser(for: .bonjour(type: bonjourType, domain: nil), using: params)

        browser.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.connectionState = .browsing
                    self.lastError = nil
                case .failed(let error):
                    self.connectionState = .failed(error.localizedDescription)
                    self.lastError = error.localizedDescription
                case .cancelled:
                    self.connectionState = .idle
                default:
                    break
                }
            }
        }

        browser.browseResultsChangedHandler = { [weak self] results, _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                var peers: [CampaignPeer] = []
                var newMap: [NWEndpoint: CampaignPeer] = [:]
                for result in results {
                    let name: String
                    if case .service(let n, _, _, _) = result.endpoint {
                        name = n
                    } else {
                        name = result.endpoint.debugDescription
                    }
                    // Reuse existing peer ID if endpoint already known
                    let peer = self.endpointPeerMap[result.endpoint]
                        ?? CampaignPeer(id: UUID(), name: name, endpointDescription: result.endpoint.debugDescription)
                    newMap[result.endpoint] = peer
                    peers.append(peer)
                }
                self.endpointPeerMap = newMap
                self.discoveredPeers = peers
            }
        }

        self.browser = browser
        browser.start(queue: networkQueue)
        connectionState = .browsing
    }

    // MARK: - Connect API

    /// Connect to a discovered host peer.
    func connect(to peer: CampaignPeer) {
        guard role == .client else { return }
        guard let endpoint = endpointPeerMap.first(where: { $0.value.id == peer.id })?.key else {
            lastError = "Endpoint not found for peer \(peer.name)"
            return
        }

        // Stop browsing
        browser?.cancel()
        browser = nil

        let params = NWParameters.tcp
        params.includePeerToPeer = true
        let connection = NWConnection(to: endpoint, using: params)

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    self.connectedPeerName = peer.name
                    self.connectionState = .connectedUnsynced(peerName: peer.name)
                    self.lastError = nil
                    self.sendHello()
                case .failed(let error):
                    self.connectionState = .failed(error.localizedDescription)
                    self.lastError = error.localizedDescription
                case .cancelled:
                    self.connectionState = .idle
                case .waiting(let error):
                    self.lastError = "Waiting: \(error.localizedDescription)"
                default:
                    break
                }
            }
        }

        clientConnection = connection
        clientParser.reset()
        lastAppliedRevision = 0
        connection.start(queue: networkQueue)
        connectionState = .connecting
        receiveClientData(on: connection)
    }

    // MARK: - Send API

    /// Client sends a message to the host.
    func sendToHost(_ message: CampaignNetworkMessage) {
        guard let connection = clientConnection else { return }
        let envelope = CampaignNetworkEnvelope(
            sessionID: sessionID ?? CampaignNetworkEnvelope.preSessionID,
            message: message
        )
        sendEnvelope(envelope, on: connection)
    }

    /// Host sends a message to a specific connected client.
    func send(_ message: CampaignNetworkMessage, to clientID: UUID) {
        guard let sessionID else { return }
        guard let connection = hostConnections[clientID] else {
            lastError = "No connection for client \(clientID)"
            return
        }
        let envelope = CampaignNetworkEnvelope(sessionID: sessionID, message: message)
        sendEnvelope(envelope, on: connection)
    }

    /// Host broadcasts a message to all connected clients.
    func broadcast(_ message: CampaignNetworkMessage) {
        guard let sessionID else { return }
        let envelope = CampaignNetworkEnvelope(sessionID: sessionID, message: message)
        for connection in hostConnections.values {
            sendEnvelope(envelope, on: connection)
        }
    }

    func sendSnapshot(_ snapshot: CampaignNetworkSnapshot, to clientID: UUID? = nil) {
        if let clientID {
            send(.snapshot(snapshot), to: clientID)
        } else {
            broadcast(.snapshot(snapshot))
        }
    }

    func broadcastDelta(_ delta: CampaignDelta) {
        currentRevision = delta.revision
        deltaLog.append(delta)
        if deltaLog.count > maxDeltaLogCount {
            deltaLog.removeFirst(deltaLog.count - maxDeltaLogCount)
        }
        broadcast(.delta(delta))
    }

    func makeDelta(
        originClientID: UUID?,
        changes: [CampaignDeltaChange]
    ) -> CampaignDelta {
        CampaignDelta(
            deltaID: UUID(),
            revision: currentRevision + 1,
            previousRevision: currentRevision,
            createdAt: Date(),
            originClientID: originClientID,
            changes: changes
        )
    }

    func recordAcceptedReceipt(_ receipt: CampaignCommandAccepted, for clientID: UUID, commandID: UUID) {
        var clientReceipts = commandReceipts[clientID] ?? [:]
        clientReceipts[commandID] = CampaignCommandResult(accepted: receipt, rejected: nil)
        commandReceipts[clientID] = clientReceipts
    }

    func recordRejectedReceipt(_ rejection: CampaignCommandRejected, for clientID: UUID, commandID: UUID) {
        var clientReceipts = commandReceipts[clientID] ?? [:]
        clientReceipts[commandID] = CampaignCommandResult(accepted: nil, rejected: rejection)
        commandReceipts[clientID] = clientReceipts
    }

    func receipt(for clientID: UUID, commandID: UUID) -> CampaignCommandResult? {
        commandReceipts[clientID]?[commandID]
    }

    func replayBatch(from lastAppliedRevision: Int) -> CampaignDeltaBatch? {
        let nextRevision = lastAppliedRevision + 1
        let deltas = deltaLog.filter { $0.revision >= nextRevision }
        guard let first = deltas.first, first.previousRevision == lastAppliedRevision else {
            return nil
        }
        guard deltas.allSatisfy({ $0.revision > lastAppliedRevision }) else {
            return nil
        }
        let sorted = deltas.sorted(by: { $0.revision < $1.revision })
        var expectedPrevious = lastAppliedRevision
        for delta in sorted {
            guard delta.previousRevision == expectedPrevious else { return nil }
            expectedPrevious = delta.revision
        }
        guard let last = sorted.last else { return nil }
        return CampaignDeltaBatch(fromRevision: nextRevision, toRevision: last.revision, deltas: sorted)
    }

    func noteSnapshotApplied(_ revision: Int) {
        lastAppliedRevision = revision
        if let peerName = connectedPeerName {
            connectionState = .ready(peerName: peerName)
        }
    }

    func noteDeltaApplied(_ revision: Int) {
        lastAppliedRevision = revision
    }

    func markSyncing() {
        if let peerName = connectedPeerName {
            connectionState = .syncing(peerName: peerName)
        }
    }

    func markStale() {
        if let peerName = connectedPeerName {
            connectionState = .stale(peerName: peerName)
        }
    }

    // MARK: - Stop

    func stop() {
        listener?.cancel()
        listener = nil
        browser?.cancel()
        browser = nil
        clientConnection?.cancel()
        clientConnection = nil

        for connection in hostConnections.values {
            connection.cancel()
        }
        hostConnections.removeAll()
        connectionIDMap.removeAll()
        connectedClients.removeAll()
        connectedClientCount = 0
        parsers.removeAll()
        clientParser.reset()
        endpointPeerMap.removeAll()
        discoveredPeers.removeAll()

        role = nil
        sessionID = nil
        sessionName = ""
        currentRevision = 0
        lastAppliedRevision = 0
        deltaLog.removeAll()
        commandReceipts.removeAll()
        connectedPeerName = nil
        connectionState = .idle
        onMessageReceived = nil
    }

    // MARK: - Host Connection Management

    private func handleNewHostConnection(_ connection: NWConnection) {
        let connectionID = UUID()
        hostConnections[connectionID] = connection
        connectionIDMap[ObjectIdentifier(connection)] = connectionID
        parsers[connectionID] = CampaignNetworkFraming.Parser()

        connection.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .ready:
                    break // Wait for hello before adding to connectedClients
                case .failed, .cancelled:
                    self.removeHostConnection(connectionID)
                default:
                    break
                }
            }
        }

        connection.start(queue: networkQueue)
        receiveHostData(on: connection, connectionID: connectionID)
    }

    private func removeHostConnection(_ connectionID: UUID) {
        hostConnections[connectionID]?.cancel()
        hostConnections.removeValue(forKey: connectionID)
        parsers.removeValue(forKey: connectionID)
        connectedClients.removeValue(forKey: connectionID)
        connectedClientCount = connectedClients.count

        // Clean up connectionIDMap
        connectionIDMap = connectionIDMap.filter { $0.value != connectionID }
    }

    /// Map from a clientID (from hello message) to the internal connection UUID.
    func connectionID(forClientID clientID: UUID) -> UUID? {
        connectedClients.first(where: { $0.value.id == clientID })?.key
    }

    // MARK: - Receive Loops

    private func receiveHostData(on connection: NWConnection, connectionID: UUID) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let data, !data.isEmpty {
                    self.processHostData(data, connectionID: connectionID)
                }
                if isComplete || error != nil {
                    self.removeHostConnection(connectionID)
                    return
                }
                self.receiveHostData(on: connection, connectionID: connectionID)
            }
        }
    }

    private func receiveClientData(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let data, !data.isEmpty {
                    self.processClientData(data)
                }
                if isComplete || error != nil {
                    self.connectionState = .failed(error?.localizedDescription ?? "Connection closed")
                    return
                }
                self.receiveClientData(on: connection)
            }
        }
    }

    // MARK: - Data Processing

    private func processHostData(_ data: Data, connectionID: UUID) {
        guard let parser = parsers[connectionID] else { return }
        do {
            let frames = try parser.append(data)
            for frame in frames {
                do {
                    let envelope = try decoder.decode(CampaignNetworkEnvelope.self, from: frame)

                    // Handle hello specially to register the client
                    if case .hello(let hello) = envelope.message {
                        guard hello.protocolVersion == CampaignNetworkEnvelope.currentSchemaVersion else {
                            let error = CampaignErrorMessage(
                                code: "unsupportedProtocol",
                                message: "Client protocolVersion \(hello.protocolVersion) is not supported"
                            )
                            if let hostConnection = hostConnections[connectionID] {
                                sendEnvelope(
                                    CampaignNetworkEnvelope(
                                        sessionID: sessionID ?? CampaignNetworkEnvelope.preSessionID,
                                        message: .error(error)
                                    ),
                                    on: hostConnection
                                )
                            }
                            continue
                        }
                        connectedClients[connectionID] = ConnectedClient(
                            id: hello.clientID,
                            displayName: hello.displayName)
                        connectedClientCount = connectedClients.count
                        if let hostConnection = hostConnections[connectionID] {
                            sendEnvelope(
                                CampaignNetworkEnvelope(
                                    sessionID: CampaignNetworkEnvelope.preSessionID,
                                    message: .welcome(
                                        CampaignNetworkWelcome(
                                            sessionID: sessionID ?? CampaignNetworkEnvelope.preSessionID,
                                            sessionName: sessionName,
                                            protocolVersion: CampaignNetworkEnvelope.currentSchemaVersion,
                                            currentRevision: currentRevision,
                                            heartbeatIntervalMs: 10_000,
                                            deltaRetentionLimit: maxDeltaLogCount
                                        )
                                    )
                                ),
                                on: hostConnection
                            )
                        }
                    }

                    // Resolve to the client's declared UUID
                    let clientID = connectedClients[connectionID]?.id
                    onMessageReceived?(envelope, clientID)
                } catch {
                    lastError = "Decode error from client \(connectionID): \(error.localizedDescription)"
                }
            }
        } catch {
            lastError = "Frame error from client \(connectionID): \(error.localizedDescription)"
        }
    }

    private func processClientData(_ data: Data) {
        do {
            let frames = try clientParser.append(data)
            for frame in frames {
                do {
                    let envelope = try decoder.decode(CampaignNetworkEnvelope.self, from: frame)

                    if case .welcome(let welcome) = envelope.message {
                        sessionID = welcome.sessionID
                        currentRevision = welcome.currentRevision
                        sessionName = welcome.sessionName
                        markSyncing()
                    } else if case .snapshot(let snapshot) = envelope.message {
                        sessionID = envelope.sessionID
                        currentRevision = snapshot.revision
                    } else if case .delta(let delta) = envelope.message {
                        sessionID = envelope.sessionID
                        currentRevision = delta.revision
                    } else if sessionID == nil || sessionID != envelope.sessionID {
                        sessionID = envelope.sessionID
                    }

                    onMessageReceived?(envelope, nil)
                } catch {
                    lastError = "Decode error from host: \(error.localizedDescription)"
                }
            }
        } catch {
            lastError = "Frame error from host: \(error.localizedDescription)"
        }
    }

    // MARK: - Send Helper

    private func sendEnvelope(_ envelope: CampaignNetworkEnvelope, on connection: NWConnection) {
        do {
            let framed = try CampaignNetworkFraming.encode(envelope, encoder: encoder)
            connection.send(content: framed, completion: .contentProcessed { [weak self] error in
                if let error {
                    Task { @MainActor [weak self] in
                        self?.lastError = "Send error: \(error.localizedDescription)"
                    }
                }
            })
        } catch {
            lastError = "Encode error: \(error.localizedDescription)"
        }
    }

    private func sendHello() {
        let hello = CampaignNetworkMessage.hello(
            .init(clientID: clientID, displayName: ProcessInfo.processInfo.hostName)
        )
        sendToHost(hello)
    }
}
