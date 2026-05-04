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
    var isInTracker: Bool = false
    var onToggleTracker: (() -> Void)? = nil

    var body: some View {
        if let player {
            PlayerCharacterDetailView(
                player: player,
                encounterCombatent: combatent,
                allSpells: allSpells,
                onRollAbility: onRollAbility,
                onRollSkill: onRollSkill,
                onCastSpell: onCastSpell,
                onUseAction: onUseAction,
                isInTracker: isInTracker,
                onToggleTracker: onToggleTracker
            )
        } else if let monster {
            MonsterDetailView(
                monster: monster,
                encounterCombatent: combatent,
                allSpells: allSpells,
                onRollAbility: onRollAbility,
                onRollSkill: onRollSkill,
                onCastSpell: onCastSpell,
                isInTracker: isInTracker,
                onToggleTracker: onToggleTracker
            )
        } else if let npc {
            NPCDetailView(
                npc: npc,
                encounterCombatent: combatent,
                allSpells: allSpells,
                onRollAbility: onRollAbility,
                onRollSkill: onRollSkill,
                onCastSpell: onCastSpell,
                onUseAction: onUseAction,
                isInTracker: isInTracker,
                onToggleTracker: onToggleTracker
            )
        } else {
            CombatentDetailView(combatent: combatent)
        }
    }
}
