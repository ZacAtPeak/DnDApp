import SwiftUI

struct InitiativeTrackerStrip: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Initiative Tracker")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
                .padding(.top)

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 16) {
                    if viewModel.combatents.isEmpty {
                        emptyState
                    } else {
                        ForEach($viewModel.combatents) { $combatent in
                            InitiativeCard(
                                combatent: combatent,
                                isSelected: viewModel.selectedInitiativeCombatentID == combatent.id
                            ) {
                                viewModel.selectOrAssignStatus(to: combatent)
                            } onEdit: {
                                viewModel.beginEditing(combatentID: combatent.id)
                            } onStatusDrop: { payloads in
                                viewModel.assignDraggedStatus(from: payloads, to: combatent.id)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(.bar)
        .overlay {
            if viewModel.isInitiativeTargeted {
                Rectangle()
                    .stroke(Color.accentColor, lineWidth: 2)
                    .allowsHitTesting(false)
            }
        }
        .dropDestination(for: String.self) { ids, _ in
            viewModel.addCombatents(from: ids)
        } isTargeted: { targeted in
            viewModel.isInitiativeTargeted = targeted
        }
    }

    private var emptyState: some View {
        Text("Drag characters here to add them to initiative")
            .foregroundStyle(.secondary)
            .font(.subheadline)
            .frame(minWidth: 300)
            .padding(.vertical, 8)
    }
}
