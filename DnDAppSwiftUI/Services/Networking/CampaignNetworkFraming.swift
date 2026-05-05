import Foundation

/// Length-prefixed framing for TCP streams.
///
/// Wire format: [4-byte big-endian length][JSON payload of that length]
///
/// The parser accumulates data from TCP chunks and emits complete frames.
enum CampaignNetworkFraming {

    /// Maximum allowed frame payload size (16 MB).
    nonisolated static let maxFrameSize: UInt32 = 16 * 1024 * 1024

    // MARK: - Encode

    /// Wraps a JSON payload in a length-prefixed frame.
    nonisolated static func frame(_ data: Data) -> Data {
        var length = UInt32(data.count).bigEndian
        var framed = Data(bytes: &length, count: 4)
        framed.append(data)
        return framed
    }

    /// Encodes a `Codable` value to a length-prefixed frame.
    nonisolated static func encode<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        let json = try encoder.encode(value)
        return frame(json)
    }

    // MARK: - Streaming Parser

    /// Accumulates TCP chunks and extracts complete frames.
    /// Thread-safe via NSLock for use on network dispatch queues.
    final class Parser: @unchecked Sendable {
        private var buffer = Data()
        private let lock = NSLock()

        nonisolated init() {}

        enum ParseError: Error, Equatable, Sendable {
            case frameTooLarge(UInt32)
        }

        /// Appends incoming data and returns all complete frame payloads.
        /// Throws `ParseError.frameTooLarge` if a frame header exceeds `maxFrameSize`,
        /// discarding the offending 4-byte header and continuing.
        nonisolated func append(_ data: Data) throws -> [Data] {
            lock.lock()
            defer { lock.unlock() }

            buffer.append(data)
            var frames: [Data] = []
            var offset = 0

            while buffer.count - offset >= 4 {
                // Read 4-byte big-endian length
                let headerBytes: [UInt8] = [
                    buffer[buffer.startIndex + offset],
                    buffer[buffer.startIndex + offset + 1],
                    buffer[buffer.startIndex + offset + 2],
                    buffer[buffer.startIndex + offset + 3]
                ]
                let length = UInt32(headerBytes[0]) << 24
                    | UInt32(headerBytes[1]) << 16
                    | UInt32(headerBytes[2]) << 8
                    | UInt32(headerBytes[3])

                if length > CampaignNetworkFraming.maxFrameSize {
                    offset += 4
                    // Compact buffer before throwing
                    buffer = Data(buffer.suffix(from: buffer.startIndex + offset))
                    throw ParseError.frameTooLarge(length)
                }

                let totalNeeded = 4 + Int(length)
                guard buffer.count - offset >= totalNeeded else { break }

                let payloadStart = buffer.startIndex + offset + 4
                let payloadEnd = buffer.startIndex + offset + totalNeeded
                let payload = Data(buffer[payloadStart ..< payloadEnd])
                frames.append(payload)
                offset += totalNeeded
            }

            // Compact: remove consumed bytes
            if offset > 0 {
                buffer = Data(buffer.suffix(from: buffer.startIndex + offset))
            }

            return frames
        }

        /// Resets the internal buffer (e.g. on disconnect).
        nonisolated func reset() {
            lock.lock()
            buffer = Data()
            lock.unlock()
        }
    }
}
