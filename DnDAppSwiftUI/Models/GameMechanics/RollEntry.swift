import Foundation

struct RollEntry: Identifiable, Codable {
    let id = UUID()
    let type: String
    let name: String
    let roll: Int
    let modifier: Int
    let total: Double
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case type, name, roll, modifier, total, timestamp
    }
}
