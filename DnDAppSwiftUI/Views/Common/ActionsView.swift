import SwiftUI

struct ActionsView: View {
    let actions: [Attack]

    var body: some View {
        DetailSection(title: "Actions") {
            if actions.isEmpty {
                Text("No actions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(actions, id: \.name) { action in
                    DescriptionRow(
                        title: action.name,
                        detail: "+\(action.hitBonus) to hit, \(action.reach), \(action.damageRoll) \(action.damageType.rawValue)"
                    )
                }
            }
        }
    }
}
