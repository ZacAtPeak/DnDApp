import Foundation

struct SidebarItem: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    var children: [SidebarItem]?
}
