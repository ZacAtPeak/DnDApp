import SwiftUI

struct CampaignDetailPane: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let selectedInitiativeCombatent = viewModel.selectedInitiativeCombatent {
                    let entityName = viewModel.selectedPlayer?.name ?? viewModel.selectedMonster?.name ?? viewModel.selectedNPC?.name ?? selectedInitiativeCombatent.name
                    let entityID = viewModel.selectedPlayer?.id ?? viewModel.selectedMonster?.id ?? viewModel.selectedNPC?.id
                    let entityType: InventoryEntityType? = viewModel.selectedPlayer != nil ? .player : viewModel.selectedMonster != nil ? .monster : viewModel.selectedNPC != nil ? .npc : nil
                    InitiativeSelectionDetailView(
                        combatent: selectedInitiativeCombatent,
                        player: viewModel.selectedPlayer,
                        monster: viewModel.selectedMonster,
                        npc: viewModel.selectedNPC,
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
                        }
                    )
                } else if let selectedPlayer = viewModel.selectedPlayer {
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
                        }
                    )
                } else if let selectedMonster = viewModel.selectedMonster {
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
                        }
                    )
                } else if let selectedNPC = viewModel.selectedNPC {
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
                        }
                    )
                } else if let selectedWikiEntry = viewModel.selectedWikiEntry {
                    WikiDetailView(entry: selectedWikiEntry)
                } else if let selectedLootItem = viewModel.selectedLootItem {
                    LootDetailView(item: selectedLootItem)
                } else if let selectedSpell = viewModel.selectedSpellEntry {
                    SpellDetailView(spell: selectedSpell)
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
