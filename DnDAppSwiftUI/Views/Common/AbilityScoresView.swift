import SwiftUI

struct AbilityScoresView: View {
    let scores: AbilityScores
    var modifiedAbilities: Set<String> = []
    var onRoll: ((String, Int) -> Void)?

    var body: some View {
        DetailSection(title: "Ability Scores") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 8) {
                abilityScoreCell(label: "STR", value: scores.strength, modifier: scores.strMod)
                abilityScoreCell(label: "DEX", value: scores.dexterity, modifier: scores.dexMod)
                abilityScoreCell(label: "CON", value: scores.constitution, modifier: scores.conMod)
                abilityScoreCell(label: "INT", value: scores.intelligence, modifier: scores.intMod)
                abilityScoreCell(label: "WIS", value: scores.wisdom, modifier: scores.wisMod)
                abilityScoreCell(label: "CHA", value: scores.charisma, modifier: scores.chaMod)
            }
        }
    }

    private func abilityScoreCell(label: String, value: Int, modifier: Int) -> some View {
        let isModified = modifiedAbilities.contains(label)
        let cell = AbilityScoreCell(label: label, value: value, modifier: modifier, isModified: isModified)
        if let onRoll {
            return AnyView(
                Button {
                    onRoll(label, modifier)
                } label: {
                    cell
                }
                .buttonStyle(.plain)
            )
        }
        return AnyView(cell)
    }
}
