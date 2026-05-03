import SwiftUI

struct CreatureSummaryGrid: View {
    let armorClass: Int
    let armorSource: String
    var acBonus: Int = 0
    let hitDice: String
    let initiative: Double
    let speed: MovementSpeed
    let senses: Senses
    let languages: [String]

    private let columns = [
        GridItem(.adaptive(minimum: 160), alignment: .topLeading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            SummaryMetric(
                title: "Armor Class",
                value: acBonus > 0
                    ? "\(armorClass + acBonus) \(armorSource) (+\(acBonus) eq.)"
                    : "\(armorClass) \(armorSource)"
            )
            SummaryMetric(title: "Hit Dice", value: hitDice)
            SummaryMetric(title: "Initiative", value: "\(Int(initiative))")
            SummaryMetric(title: "Speed", value: speedText)
            SummaryMetric(title: "Senses", value: sensesText)

            if !languages.isEmpty {
                SummaryMetric(title: "Languages", value: languages.joined(separator: ", "))
            }
        }
    }

    private var speedText: String {
        var parts = ["\(speed.walk) ft."]
        if let swim = speed.swim { parts.append("swim \(swim) ft.") }
        if let fly = speed.fly { parts.append("fly \(fly) ft.\(speed.hover ? " hover" : "")") }
        if let climb = speed.climb { parts.append("climb \(climb) ft.") }
        if let burrow = speed.burrow { parts.append("burrow \(burrow) ft.") }
        return parts.joined(separator: ", ")
    }

    private var sensesText: String {
        var parts: [String] = []
        if let darkvision = senses.darkvision { parts.append("darkvision \(darkvision) ft.") }
        if let blindsight = senses.blindsight { parts.append("blindsight \(blindsight) ft.") }
        if let tremorsense = senses.tremorsense { parts.append("tremorsense \(tremorsense) ft.") }
        if let truesight = senses.truesight { parts.append("truesight \(truesight) ft.") }
        parts.append("passive \(senses.passivePerception)")
        return parts.joined(separator: ", ")
    }
}
