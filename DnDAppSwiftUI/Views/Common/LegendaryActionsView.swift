import SwiftUI

struct LegendaryActionsView: View {
    let actions: [LegendaryAction]
    let count: Int?

    var body: some View {
        DetailSection(title: "Legendary Actions") {
            if let count {
                Text("\(count) per round")
                    .foregroundStyle(.secondary)
            }

            ForEach(actions, id: \.name) { action in
                DescriptionRow(title: "\(action.name) (\(action.cost))", detail: action.description)
            }
        }
    }
}
