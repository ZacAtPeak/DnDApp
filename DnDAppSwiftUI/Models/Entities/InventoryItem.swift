import Foundation

struct InventoryItem: Identifiable {
    var id: UUID = UUID()
    let lootItemID: String
    var isEquipped: Bool = false
}
