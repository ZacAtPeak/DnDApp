import SwiftUI

struct InitiativeSelectionDetailView: View {
    let combatent: Combatent
    let player: PlayerCharacter?
    let monster: Monster?
    let npc: NPC?

    var body: some View {
        if let player {
            PlayerCharacterDetailView(player: player, encounterCombatent: combatent)
        } else if let monster {
            MonsterDetailView(monster: monster, encounterCombatent: combatent)
        } else if let npc {
            NPCDetailView(npc: npc, encounterCombatent: combatent)
        } else {
            CombatentDetailView(combatent: combatent)
        }
    }
}
