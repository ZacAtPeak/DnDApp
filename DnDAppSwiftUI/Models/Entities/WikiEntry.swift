import Foundation

struct WikiEntry: Identifiable {
    let id: String
    let title: String
    let description: String
    var aliases: [String] = []
}
