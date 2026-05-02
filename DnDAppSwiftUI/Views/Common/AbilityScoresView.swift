import SwiftUI

struct AbilityScoresView: View {
    let scores: AbilityScores

    var body: some View {
        DetailSection(title: "Ability Scores") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 8) {
                AbilityScoreCell(label: "STR", value: scores.strength, modifier: scores.strMod)
                AbilityScoreCell(label: "DEX", value: scores.dexterity, modifier: scores.dexMod)
                AbilityScoreCell(label: "CON", value: scores.constitution, modifier: scores.conMod)
                AbilityScoreCell(label: "INT", value: scores.intelligence, modifier: scores.intMod)
                AbilityScoreCell(label: "WIS", value: scores.wisdom, modifier: scores.wisMod)
                AbilityScoreCell(label: "CHA", value: scores.charisma, modifier: scores.chaMod)
            }
        }
    }
}
