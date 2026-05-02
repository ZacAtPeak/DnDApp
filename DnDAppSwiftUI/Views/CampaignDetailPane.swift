import SwiftUI

struct CampaignDetailPane: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let selectedInitiativeCombatent = viewModel.selectedInitiativeCombatent {
                    InitiativeSelectionDetailView(
                        combatent: selectedInitiativeCombatent,
                        player: viewModel.selectedPlayer,
                        monster: viewModel.selectedMonster,
                        npc: viewModel.selectedNPC
                    )
                } else if let selectedPlayer = viewModel.selectedPlayer {
                    PlayerCharacterDetailView(player: selectedPlayer, encounterCombatent: nil)
                } else if let selectedMonster = viewModel.selectedMonster {
                    MonsterDetailView(monster: selectedMonster, encounterCombatent: nil)
                } else if let selectedNPC = viewModel.selectedNPC {
                    NPCDetailView(npc: selectedNPC, encounterCombatent: nil)
                } else if let selectedItem = viewModel.selectedSidebarItem {
                    Text(selectedItem.title)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Detail view content goes here.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}
