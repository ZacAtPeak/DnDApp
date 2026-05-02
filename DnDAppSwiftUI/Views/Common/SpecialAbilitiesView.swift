import SwiftUI

struct SpecialAbilitiesView: View {
    let abilities: [SpecialAbility]

    var body: some View {
        DetailSection(title: "Special Abilities") {
            if abilities.isEmpty {
                Text("No special abilities")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(abilities, id: \.name) { ability in
                    DescriptionRow(title: ability.name, detail: ability.description)
                }
            }
        }
    }
}
