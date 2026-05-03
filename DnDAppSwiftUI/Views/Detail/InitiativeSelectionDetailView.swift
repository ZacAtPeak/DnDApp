import SwiftUI

struct InitiativeSelectionDetailView: View {
    let combatent: Combatent
    let player: PlayerCharacter?
    let monster: Monster?
    let npc: NPC?
    var allSpells: [SpellEntry] = spellDemoData
    var onRollAbility: ((String, Int) -> Void)?
    var onRollSkill: ((String, Int) -> Void)?
    var onCastSpell: ((SpellEntry, Int) -> Void)?
    var onUseAction: ((Attack) -> Void)?

    var body: some View {
        if let player {
            PlayerCharacterDetailView(player: player, encounterCombatent: combatent, allSpells: allSpells, onRollAbility: onRollAbility, onRollSkill: onRollSkill, onCastSpell: onCastSpell, onUseAction: onUseAction)
        } else if let monster {
            MonsterDetailView(monster: monster, encounterCombatent: combatent, allSpells: allSpells, onRollAbility: onRollAbility, onRollSkill: onRollSkill, onCastSpell: onCastSpell)
        } else if let npc {
            NPCDetailView(npc: npc, encounterCombatent: combatent, allSpells: allSpells, onRollAbility: onRollAbility, onRollSkill: onRollSkill, onCastSpell: onCastSpell)
        } else {
            CombatentDetailView(combatent: combatent)
        }
    }
}
