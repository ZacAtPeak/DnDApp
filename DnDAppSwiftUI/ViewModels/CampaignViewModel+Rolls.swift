import Foundation

// MARK: - Roll history

extension CampaignViewModel {
    func logRoll(type: String, name: String, roll: Int, modifier: Int, total: Double) {
        let entry = RollEntry(
            type: type,
            name: name,
            roll: roll,
            modifier: modifier,
            total: total,
            timestamp: Date()
        )
        rollHistory.insert(entry, at: 0)
        hasNewRollHistory = true
    }

    func clearRollHistory() {
        rollHistory.removeAll()
        hasNewRollHistory = false
    }

    func markRollHistorySeen() {
        hasNewRollHistory = false
    }

    func rollAbilityCheck(name: String, modifier: Int) {
        let roll = Int.random(in: 1...20)
        logRoll(type: "Ability", name: name, roll: roll, modifier: modifier, total: Double(roll + modifier))
    }

    func rollSkillCheck(name: String, bonus: Int) {
        let roll = Int.random(in: 1...20)
        logRoll(type: "Skill", name: name, roll: roll, modifier: bonus, total: Double(roll + bonus))
    }
}
