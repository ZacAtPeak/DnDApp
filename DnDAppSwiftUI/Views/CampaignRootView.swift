import SwiftUI

struct CampaignRootView: View {
    @State private var viewModel = CampaignViewModel(dataService: CampaignDataService.shared)

    private var isShowingCombatentEditor: Binding<Bool> {
        Binding {
            viewModel.editingCombatentID != nil
        } set: { isShowing in
            if !isShowing {
                viewModel.dismissEditor()
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            CampaignSidebar(viewModel: viewModel)
        } detail: {
            NavigationStack {
                VStack(alignment: .leading, spacing: 0) {
                    InitiativeTrackerStrip(viewModel: viewModel)
                    Divider()
                    CampaignDetailPane(viewModel: viewModel)
                }
                .toolbar {
                    CampaignToolbar(viewModel: viewModel)
                }
                .sheet(isPresented: isShowingCombatentEditor) {
                    if let editingCombatent = viewModel.editingCombatent {
                        InitiativeEditorView(combatent: editingCombatent)
                    }
                }
            }
        }
    }
}
