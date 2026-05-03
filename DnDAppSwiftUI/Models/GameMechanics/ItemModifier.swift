import Foundation

enum ItemModifier: Hashable {
    case acBonus(Int)
    case savingThrowBonus(Int)
    case attackBonus(Int)
    case damageBonus(Int)
    case setAbilityScore(String, Int) // ability: "STR" | "DEX" | "CON" | "INT" | "WIS" | "CHA"

    var displayText: String {
        switch self {
        case .acBonus(let v):              return "+\(v) AC"
        case .savingThrowBonus(let v):     return "+\(v) to saving throws"
        case .attackBonus(let v):          return "+\(v) to attack rolls"
        case .damageBonus(let v):          return "+\(v) to damage rolls"
        case .setAbilityScore(let a, let v): return "\(a) set to \(v)"
        }
    }
}
