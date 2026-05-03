import Foundation

struct Attack: Identifiable {
    var id: UUID = UUID()
    var name: String
    var hitBonus: Int
    var reach: String
    var damageRoll: String
    var damageType: DamageType
    var description: String?
    var maxUses: Int? = nil
    var remainingUses: Int? = nil
}
