import SwiftUI

struct InitiativeTrackerStrip: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Initiative Tracker")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        viewModel.rewindTurn()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.combatents.isEmpty)

                    Button {
                        viewModel.advanceTurn()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.combatents.isEmpty)
                }

                Menu {
                    Button("Add Lair Action") {
                        viewModel.addLairAction()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top)

            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 16) {
                    if viewModel.combatents.isEmpty {
                        emptyState
                    } else {
                        ForEach($viewModel.combatents) { $combatent in
                            InitiativeCard(
                                combatent: $combatent,
                                isSelected: viewModel.selectedInitiativeCombatentID == combatent.id
                            ) {
                                viewModel.selectOrAssignStatus(to: combatent)
                            } onEdit: {
                                viewModel.beginEditing(combatentID: combatent.id)
                            } onRemove: {
                                viewModel.removeCombatent(id: combatent.id)
                            } onMakeTurn: {
                                viewModel.makeCurrentTurn(for: combatent.id)
                            } onStatusDrop: { payloads in
                                viewModel.assignDraggedStatus(from: payloads, to: combatent.id)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
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
