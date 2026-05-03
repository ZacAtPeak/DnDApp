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
            Menu {
                Button("Statuses") {
                    viewModel.isStatusPalettePresented = true
                }
                Button("Loot Generator") {}
                Button("Inventory Generator") {}
            } label: {
                Label("Tools", systemImage: "wrench.and.screwdriver")
            }
            .popover(isPresented: $viewModel.isStatusPalettePresented) {
                StatusPaletteView(statuses: viewModel.assignableStatuses) { status in
                    viewModel.queueStatus(status)
                }
            }
            .help("Tools")
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
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItem {
            Button {
                viewModel.isRollHistoryPresented.toggle()
                if viewModel.isRollHistoryPresented {
                    viewModel.markRollHistorySeen()
                }
            } label: {
                ZStack {
                    Label("Roll History", systemImage: "dice")
                    if viewModel.hasNewRollHistory {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 10, y: -8)
                    }
                }
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
