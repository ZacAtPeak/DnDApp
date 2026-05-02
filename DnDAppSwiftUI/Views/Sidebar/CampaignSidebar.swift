import SwiftUI

struct CampaignSidebar: View {
    @Bindable var viewModel: CampaignViewModel

    private var sidebarSelection: Binding<String?> {
        Binding {
            viewModel.selectedItemID
        } set: { newSelection in
            viewModel.selectSidebarItem(newSelection)
        }
    }

    var body: some View {
        List(sidebarItems, children: \.children, selection: sidebarSelection) { item in
            Label(item.title, systemImage: item.systemImage)
                .draggable(item.id)
        }
        .navigationTitle("Navigation")
    }
}
