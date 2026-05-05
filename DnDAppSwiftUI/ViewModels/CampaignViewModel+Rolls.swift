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
        rollHistory.append(entry)
        hasNewRollHistory = true
        publishNetworkSnapshot(reason: "roll logged")
    }

    func clearRollHistory() {
        rollHistory.removeAll()
        hasNewRollHistory = false
        publishNetworkSnapshot(reason: "roll history cleared")
    }

    func markRollHistorySeen() {
        hasNewRollHistory = false
    }

    func saveRollHistory() {
        guard !rollHistory.isEmpty else { return }

        struct SavedEncounter: Codable {
            let savedAt: Date
            let rolls: [RollEntry]
        }

        let encounter = SavedEncounter(savedAt: Date(), rolls: rollHistory)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(encounter)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let filename = "encounter_\(formatter.string(from: Date())).json"

            guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not find Documents directory")
                return
            }

            let fileURL = docsURL.appendingPathComponent(filename)
            try data.write(to: fileURL)
            clearRollHistory()
            print("Saved encounter to \(fileURL.path)")
        } catch {
            print("Failed to save encounter: \(error)")
        }
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
