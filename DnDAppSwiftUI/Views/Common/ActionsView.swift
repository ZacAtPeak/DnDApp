import SwiftUI

struct ActionsView: View {
    let actions: [Attack]
    var onUseAction: ((Attack) -> Void)?

    var body: some View {
        DetailSection(title: "Actions") {
            if actions.isEmpty {
                Text("No actions")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(actions, id: \.id) { action in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(action.name)
                                .font(.headline)

                            WikiLinkedText(
                                text: "+\(action.hitBonus) to hit, \(action.reach), \(action.damageRoll) \(action.damageType.rawValue)"
                            )
                            .foregroundStyle(.secondary)

                            if let remaining = action.remainingUses, let max = action.maxUses {
                                Text("\(remaining)/\(max) uses")
                                    .font(.caption)
                                    .foregroundStyle(remaining == 0 ? .red : .secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let onUseAction {
                            Button("Use") {
                                onUseAction(action)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            .disabled(action.remainingUses == 0)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
