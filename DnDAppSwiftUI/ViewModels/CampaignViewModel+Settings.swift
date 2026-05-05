import Foundation

extension CampaignViewModel {
    /// Removes all demo data. Globals are cleared so sidebar/search show nothing.
    /// DemoDataStore retains the immutable originals for restore.
    func removeDemoData() {
        // Clear mutable globals (sidebar, search, detail views read these).
        testPlayers.removeAll()
        testMonsters.removeAll()
        testNPCs.removeAll()

        // Clear VM-owned data.
        encounters.removeAll()
        playerInventories.removeAll()
        monsterInventories.removeAll()
        npcInventories.removeAll()
        combatents.removeAll()
        rollHistory.removeAll()
        hasNewRollHistory = false

        selectedItemID = "players"
        selectedInitiativeCombatentID = nil
        dataVersion += 1
        publishNetworkSnapshot(reason: "demo data removed")
    }

    /// Restores demo data from the immutable DemoDataStore.
    /// Safe to call even after removeDemoData() — DemoDataStore captured originals at load.
    func restoreDemoData() {
        // Restore globals from immutable store.
        testPlayers = DemoDataStore.players
        testMonsters = DemoDataStore.monsters
        testNPCs = DemoDataStore.npcs

        // Repopulate VM-derived arrays.
        encounters.removeAll()
        seedDemoEncounters()
        seedDemoInventories()

        combatents.removeAll()
        rollHistory.removeAll()
        hasNewRollHistory = false

        selectedItemID = "players"
        selectedInitiativeCombatentID = nil
        dataVersion += 1
        publishNetworkSnapshot(reason: "demo data restored")
    }

    func savedSessionFiles() -> [URL] {
        guard let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: [.creationDateKey])
            return files
                .filter { $0.pathExtension.lowercased() == "json" && $0.lastPathComponent.hasPrefix("encounter_") }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            return []
        }
    }

    func deleteSavedSession(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Failed to delete session: \(error)")
        }
    }

    // MARK: - Cached session file info

    /// File info for saved session rows, computed once and cached to avoid
    /// synchronous FileManager I/O in the view body.
    struct SessionFileInfo: Identifiable {
        let id: UUID = UUID()
        let url: URL
        let creationDate: Date
        var displayName: String { url.deletingPathExtension().lastPathComponent }
    }

    var savedSessionFileInfos: [SessionFileInfo] {
        savedSessionFiles().compactMap { url in
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let date = attrs[.creationDate] as? Date
            else { return nil }
            return SessionFileInfo(url: url, creationDate: date)
        }
    }
}
