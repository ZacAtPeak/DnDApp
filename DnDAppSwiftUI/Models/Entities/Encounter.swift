import Foundation

struct Encounter: Identifiable, Hashable {
    let id: UUID
    var name: String
    var memberSidebarIDs: [String]

    init(id: UUID = UUID(), name: String, memberSidebarIDs: [String] = []) {
        self.id = id
        self.name = name
        self.memberSidebarIDs = memberSidebarIDs
    }
}
