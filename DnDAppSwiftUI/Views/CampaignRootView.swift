import SwiftUI

struct CampaignRootView: View {
    @State private var viewModel = CampaignViewModel(dataService: CampaignDataService.shared)
    @State private var committedTrackerHeight: CGFloat = 220
    @GestureState private var trackerResizeDelta: CGFloat = 0

    private let minimumTrackerHeight: CGFloat = 120

    private var trackerHeight: CGFloat {
        max(minimumTrackerHeight, committedTrackerHeight + trackerResizeDelta)
    }

    private var isResizingTracker: Bool {
        trackerResizeDelta != 0
    }

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
        ZStack {
            NavigationSplitView {
                CampaignSidebar(viewModel: viewModel)
            } detail: {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 0) {
                        InitiativeTrackerStrip(viewModel: viewModel)
                            .frame(height: trackerHeight)

                        resizeHandle

                        CampaignDetailPane(viewModel: viewModel)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transaction { transaction in
                        if isResizingTracker {
                            transaction.disablesAnimations = true
                            transaction.animation = nil
                        }
                    }
                    .toolbar {
                        CampaignToolbar(viewModel: viewModel)
                    }
                    .confirmationDialog(
                        "Perform a Long Rest?",
                        isPresented: $viewModel.isLongRestConfirmationPresented,
                        titleVisibility: .visible
                    ) {
                        Button("Long Rest", role: .none) {
                            viewModel.longRest()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("This will restore all HP and spell slots for every combatant and player.")
                    }
                    .sheet(isPresented: isShowingCombatentEditor) {
                        if let editingCombatent = viewModel.editingCombatent {
                            InitiativeEditorView(combatent: editingCombatent)
                        }
                    }
                    .sheet(isPresented: $viewModel.isCharacterCreationPresented) {
                        CharacterCreationView { player in
                            viewModel.createPlayerCharacter(player)
                        }
                    }
                    .sheet(isPresented: $viewModel.isWikiEntryCreationPresented) {
                        WikiEntryCreationView { entry in
                            viewModel.createWikiEntry(entry)
                        }
                    }
                    .sheet(isPresented: $viewModel.isLootCreationPresented) {
                        LootEntryCreationView { item in
                            viewModel.createLootItem(item)
                        }
                    }
                    .sheet(isPresented: $viewModel.isEncounterCreationPresented) {
                        EncounterCreationView { name in
                            viewModel.createEncounter(name: name)
                        }
                    }
                    .inspector(isPresented: $viewModel.isRollHistoryPresented) {
                        RollHistoryInspectorView(viewModel: viewModel)
                    }
                }
            }

            if viewModel.isSearchPresented {
                SearchOverlayView(viewModel: viewModel)
            }
        }
    }

    private var resizeHandle: some View {
        Color.clear
            .frame(height: 8)
            .contentShape(Rectangle())
            .overlay(
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 2)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($trackerResizeDelta) { value, state, transaction in
                        transaction.disablesAnimations = true
                        transaction.animation = nil
                        state = value.translation.height
                    }
                    .onEnded { value in
                        var transaction = Transaction(animation: nil)
                        transaction.disablesAnimations = true

                        withTransaction(transaction) {
                            committedTrackerHeight = max(minimumTrackerHeight, committedTrackerHeight + value.translation.height)
                        }
                    }
            )
    }
}
