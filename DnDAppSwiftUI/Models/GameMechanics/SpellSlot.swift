import Foundation

struct SpellSlot {
    var level: Int
    var max: Int
    var available: Int
}

extension Array where Element == SpellSlot {
    func normalizedToLevel9() -> [SpellSlot] {
        guard !isEmpty else { return [] }
        let existing = Dictionary(uniqueKeysWithValues: map { ($0.level, $0) })
        return (1...9).map { level in
            if let slot = existing[level] {
                return SpellSlot(level: level, max: slot.max, available: slot.available)
            } else {
                return SpellSlot(level: level, max: 0, available: 0)
            }
        }
    }
}
