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
                SidebarRow(item: item, expandedIDs: $expandedIDs, viewModel: viewModel)
            }
        }
        .navigationTitle("Navigation")
    }
}

private struct SidebarRow: View {
    let item: SidebarItem
    @Binding var expandedIDs: Set<String>
    @Bindable var viewModel: CampaignViewModel

    private var isExpanded: Binding<Bool> {
        Binding {
            expandedIDs.contains(item.id)
        } set: { newValue in
            if newValue { expandedIDs.insert(item.id) }
            else { expandedIDs.remove(item.id) }
        }
    }

    var body: some View {
        if let children = item.children {
            DisclosureGroup(isExpanded: isExpanded) {
                ForEach(children) { child in
                    SidebarRow(item: child, expandedIDs: $expandedIDs, viewModel: viewModel)
                }
            } label: {
                HStack {
                    Label(item.title, systemImage: item.systemImage)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .draggable(item.id)
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    isExpanded.wrappedValue.toggle()
                }
            )
            .modifier(EncounterContextMenuModifier(itemID: item.id, viewModel: viewModel))
        } else {
            HStack {
                Label(item.title, systemImage: item.systemImage)
                Spacer()
            }
            .contentShape(Rectangle())
            .draggable(item.id)
            .modifier(EncounterContextMenuModifier(itemID: item.id, viewModel: viewModel))
        }
    }
}

private struct EncounterContextMenuModifier: ViewModifier {
    let itemID: String
    @Bindable var viewModel: CampaignViewModel

    private var encounterFolderID: UUID? {
        let prefix = "encounter-"
        guard itemID.hasPrefix(prefix), !itemID.contains("-member-") else { return nil }
        return UUID(uuidString: String(itemID.dropFirst(prefix.count)))
    }

    private var encounterMemberInfo: (encounterID: UUID, memberSidebarID: String)? {
        let prefix = "encounter-"
        guard itemID.hasPrefix(prefix) else { return nil }
        guard let memberRange = itemID.range(of: "-member-") else { return nil }
        let encounterPart = String(itemID[..<memberRange.lowerBound])
        let uuidPart = String(encounterPart.dropFirst(prefix.count))
        guard let encounterID = UUID(uuidString: uuidPart) else { return nil }
        let memberSidebarID = String(itemID[memberRange.upperBound...])
        return (encounterID, memberSidebarID)
    }

    func body(content: Content) -> some View {
        if let encounterFolderID {
            content.contextMenu {
                Button(role: .destructive) {
                    viewModel.deleteEncounter(id: encounterFolderID)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        } else if let memberInfo = encounterMemberInfo {
            content.contextMenu {
                Button(role: .destructive) {
                    viewModel.removeMemberFromEncounter(
                        encounterID: memberInfo.encounterID,
                        memberSidebarID: memberInfo.memberSidebarID
                    )
                } label: {
                    Label("Remove from Encounter", systemImage: "person.badge.minus")
                }
            }
        } else {
            content
        }
    }
}
