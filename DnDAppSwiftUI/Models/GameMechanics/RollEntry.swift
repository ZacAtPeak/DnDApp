import Foundation

struct RollEntry: Identifiable {
    let id = UUID()
    let type: String
    let name: String
    let roll: Int
    let modifier: Int
    let total: Double
    let timestamp: Date
}
