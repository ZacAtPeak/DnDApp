import SwiftUI

struct CampaignDetailPane: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let selectedInitiativeCombatent = viewModel.selectedInitiativeCombatent {
                    let linkedPlayer = viewModel.combatentLinkedPlayer
                    let linkedMonster = viewModel.combatentLinkedMonster
                    let linkedNPC = viewModel.combatentLinkedNPC
                    let entityName = linkedPlayer?.name ?? linkedMonster?.name ?? linkedNPC?.name ?? selectedInitiativeCombatent.name
                    let entityID = linkedPlayer?.id ?? linkedMonster?.id ?? linkedNPC?.id
                    let entityType: InventoryEntityType? = linkedPlayer != nil ? .player : linkedMonster != nil ? .monster : linkedNPC != nil ? .npc : nil
                    let sidebarID = selectedInitiativeCombatent.sourceSidebarID
                    InitiativeSelectionDetailView(
                        combatent: selectedInitiativeCombatent,
                        player: linkedPlayer,
                        monster: linkedMonster,
                        npc: linkedNPC,
                        allSpells: viewModel.spellEntries,
                        onRollAbility: { name, modifier in
                            viewModel.rollAbilityCheck(name: "\(entityName) — \(name)", modifier: modifier)
                        },
                        onRollSkill: { name, bonus in
                            viewModel.rollSkillCheck(name: "\(entityName) — \(name)", bonus: bonus)
                        },
                        onCastSpell: { spell, slotLevel in
                            if let entityID, let entityType {
                                viewModel.castSpell(spell, atLevel: slotLevel, forEntity: entityID, entityType: entityType, name: entityName)
                            }
                        },
                        onUseAction: { action in
                            if let entityID, let entityType {
                                viewModel.useAction(action, forEntity: entityID, entityType: entityType, name: entityName)
                            }
                        },
                        isInTracker: sidebarID.map { viewModel.isInTracker(sidebarID: $0) } ?? false,
                        onToggleTracker: {
                            if let sidebarID {
                                viewModel.toggleTracker(sidebarID: sidebarID)
                            }
                        }
                    )
                } else if let selectedPlayer = viewModel.selectedPlayer {
                    let sidebarID = "player-\(selectedPlayer.id.uuidString)"
                    PlayerCharacterDetailView(
                        player: selectedPlayer,
                        encounterCombatent: nil,
                        inventory: viewModel.selectedPlayerInventory,
                        allLoot: viewModel.lootItems,
                        allSpells: viewModel.spellEntries,
                        onToggleEquip: { id in
                            viewModel.toggleEquip(inventoryItemID: id, forEntity: selectedPlayer.id, entityType: .player)
                        },
                        onRollAbility: { name, modifier in
                            viewModel.rollAbilityCheck(name: "\(selectedPlayer.name) — \(name)", modifier: modifier)
                        },
                        onRollSkill: { name, bonus in
                            viewModel.rollSkillCheck(name: "\(selectedPlayer.name) — \(name)", bonus: bonus)
                        },
                        onCastSpell: { spell, slotLevel in
                            viewModel.castSpell(spell, atLevel: slotLevel, forEntity: selectedPlayer.id, entityType: .player, name: selectedPlayer.name)
                        },
                        onUseAction: { action in
                            viewModel.useAction(action, forEntity: selectedPlayer.id, entityType: .player, name: selectedPlayer.name)
                        },
                        isInTracker: viewModel.isInTracker(sidebarID: sidebarID),
                        onToggleTracker: {
                            viewModel.toggleTracker(sidebarID: sidebarID)
                        }
                    )
                } else if let selectedMonster = viewModel.selectedMonster {
                    let sidebarID = "monster-\(selectedMonster.id.uuidString)"
                    MonsterDetailView(
                        monster: selectedMonster,
                        encounterCombatent: nil,
                        inventory: viewModel.selectedMonsterInventory,
                        allLoot: viewModel.lootItems,
                        allSpells: viewModel.spellEntries,
                        onToggleEquip: { id in
                            viewModel.toggleEquip(inventoryItemID: id, forEntity: selectedMonster.id, entityType: .monster)
                        },
                        onRollAbility: { name, modifier in
                            viewModel.rollAbilityCheck(name: "\(selectedMonster.name) — \(name)", modifier: modifier)
                        },
                        onRollSkill: { name, bonus in
                            viewModel.rollSkillCheck(name: "\(selectedMonster.name) — \(name)", bonus: bonus)
                        },
                        onCastSpell: { spell, slotLevel in
                            viewModel.castSpell(spell, atLevel: slotLevel, forEntity: selectedMonster.id, entityType: .monster, name: selectedMonster.name)
                        },
                        isInTracker: viewModel.isInTracker(sidebarID: sidebarID),
                        onToggleTracker: {
                            viewModel.toggleTracker(sidebarID: sidebarID)
                        }
                    )
                } else if let selectedNPC = viewModel.selectedNPC {
                    let sidebarID = "character-\(selectedNPC.id.uuidString)"
                    NPCDetailView(
                        npc: selectedNPC,
                        encounterCombatent: nil,
                        inventory: viewModel.selectedNPCInventory,
                        allLoot: viewModel.lootItems,
                        allSpells: viewModel.spellEntries,
                        onToggleEquip: { id in
                            viewModel.toggleEquip(inventoryItemID: id, forEntity: selectedNPC.id, entityType: .npc)
                        },
                        onRollAbility: { name, modifier in
                            viewModel.rollAbilityCheck(name: "\(selectedNPC.name) — \(name)", modifier: modifier)
                        },
                        onRollSkill: { name, bonus in
                            viewModel.rollSkillCheck(name: "\(selectedNPC.name) — \(name)", bonus: bonus)
                        },
                        onCastSpell: { spell, slotLevel in
                            viewModel.castSpell(spell, atLevel: slotLevel, forEntity: selectedNPC.id, entityType: .npc, name: selectedNPC.name)
                        },
                        onUseAction: { action in
                            viewModel.useAction(action, forEntity: selectedNPC.id, entityType: .npc, name: selectedNPC.name)
                        },
                        isInTracker: viewModel.isInTracker(sidebarID: sidebarID),
                        onToggleTracker: {
                            viewModel.toggleTracker(sidebarID: sidebarID)
                        }
                    )
                } else if let selectedWikiEntry = viewModel.selectedWikiEntry {
                    WikiDetailView(entry: selectedWikiEntry)
                } else if let selectedLootItem = viewModel.selectedLootItem {
                    LootDetailView(item: selectedLootItem)
                } else if let selectedSpell = viewModel.selectedSpellEntry {
                    SpellDetailView(spell: selectedSpell)
                } else if let selectedAsset = viewModel.selectedAsset {
                    AssetDetailView(asset: selectedAsset)
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
        .environment(\.wikiEntries, viewModel.wikiEntries)
        .environment(\.navigateToWikiEntry) { entry in
            viewModel.selectSidebarItem("wiki-\(entry.id)")
        }
        .environment(\.navigateToLootItem) { item in
            viewModel.selectSidebarItem("loot-\(item.id)")
        }
        .environment(\.navigateToSpellEntry) { spell in
            viewModel.selectSidebarItem("spell-\(spell.id)")
        }
    }
}
