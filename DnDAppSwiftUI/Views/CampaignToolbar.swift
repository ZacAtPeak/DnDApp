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
                Button("Private Asset") {}
                Button("Public Asset") {}
                Button("Statuses") {
                    viewModel.isStatusPalettePresented = true
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}
