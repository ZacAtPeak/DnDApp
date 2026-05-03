import Foundation

struct SpellEntry: Identifiable {
    let id: String
    let name: String
    let level: Int // 0 = cantrip
    let school: String
    let castingTime: String
    let range: String
    let components: String
    let duration: String
    let description: String
    var concentration: Bool = false
    var ritual: Bool = false
    var damageRoll: String? = nil
    var damageType: DamageType? = nil
}
