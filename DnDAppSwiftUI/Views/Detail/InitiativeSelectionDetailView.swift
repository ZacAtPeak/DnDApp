import SwiftUI

struct InitiativeSelectionDetailView: View {
    let combatent: Combatent
    let player: PlayerCharacter?
    let monster: Monster?
    let npc: NPC?
    var onRollAbility: ((String, Int) -> Void)?
    var onRollSkill: ((String, Int) -> Void)?

    var body: some View {
        if let player {
            PlayerCharacterDetailView(player: player, encounterCombatent: combatent, onRollAbility: onRollAbility, onRollSkill: onRollSkill)
        } else if let monster {
            MonsterDetailView(monster: monster, encounterCombatent: combatent, onRollAbility: onRollAbility, onRollSkill: onRollSkill)
        } else if let npc {
            NPCDetailView(npc: npc, encounterCombatent: combatent, onRollAbility: onRollAbility, onRollSkill: onRollSkill)
        } else {
            CombatentDetailView(combatent: combatent)
        }
    }
}
