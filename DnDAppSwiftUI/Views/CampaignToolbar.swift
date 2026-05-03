import SwiftUI

struct CampaignToolbar: ToolbarContent {
    @Bindable var viewModel: CampaignViewModel

    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                viewModel.isLongRestConfirmationPresented = true
            } label: {
                Label("Long Rest", systemImage: "bed.double")
            }
            .help("Long Rest")
        }

        ToolbarItem {
            Button {
                viewModel.isStatusPalettePresented.toggle()
            } label: {
                Label(viewModel.statusPaletteButtonTitle, systemImage: "cross.case")
            }
            .popover(isPresented: $viewModel.isStatusPalettePresented) {
                StatusPaletteView(statuses: viewModel.assignableStatuses) { status in
                    viewModel.queueStatus(status)
                }
            }
            .help(viewModel.statusPaletteHelpText)
        }

        ToolbarItem {
            Menu {
                Button("Character") {
                    viewModel.isCharacterCreationPresented = true
                }
                Button("Wiki Entry") {
                    viewModel.isWikiEntryCreationPresented = true
                }
                Button("Private Asset") {}
                Button("Public Asset") {}
                Button("Statuses") {
                    viewModel.isStatusPalettePresented = true
                }
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItem {
            Button {
                viewModel.isRollHistoryPresented.toggle()
            } label: {
                Label("Roll History", systemImage: "dice")
            }
            .help("Show roll history")
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isSearchPresented = true
                }
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
            .help("Search across all content")
            .keyboardShortcut("f", modifiers: .command)
        }
    }
}
