import SwiftUI

struct CampaignSidebar: View {
    @Bindable var viewModel: CampaignViewModel
    @State private var expandedIDs: Set<String> = []

    private var sidebarSelection: Binding<String?> {
        Binding {
            viewModel.selectedItemID
        } set: { newSelection in
            viewModel.selectSidebarItem(newSelection)
        }
    }

    var body: some View {
        List(selection: sidebarSelection) {
            ForEach(viewModel.sidebarItems) { item in
                SidebarRow(item: item, expandedIDs: $expandedIDs)
            }
        }
        .navigationTitle("Navigation")
    }
}

private struct SidebarRow: View {
    let item: SidebarItem
    @Binding var expandedIDs: Set<String>

    private var isExpanded: Binding<Bool> {
        Binding {
            expandedIDs.contains(item.id)
        } set: { newValue in
            if newValue { expandedIDs.insert(item.id) }
            else { expandedIDs.remove(item.id) }
        }
    }

    var body: some View {
        if let children = item.children, !children.isEmpty {
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(children) { child in
                    SidebarRow(item: child, expandedIDs: $expandedIDs)
                }
            } label: {
                Label(item.title, systemImage: item.systemImage)
                    .draggable(item.id)
                    .simultaneousGesture(
                        TapGesture(count: 2).onEnded {
                            isExpanded.wrappedValue.toggle()
                        }
                    )
            }
        } else {
            Label(item.title, systemImage: item.systemImage)
                .draggable(item.id)
        }
    }
}
