import SwiftUI

// MARK: - Environment Key

private struct WikiEntriesKey: EnvironmentKey {
    static let defaultValue: [WikiEntry] = []
}

extension EnvironmentValues {
    var wikiEntries: [WikiEntry] {
        get { self[WikiEntriesKey.self] }
        set { self[WikiEntriesKey.self] = newValue }
    }
}

// MARK: - WikiLinkedText

struct WikiLinkedText: View {
    let text: String

    @Environment(\.wikiEntries) private var wikiEntries
    @State private var presentedEntry: WikiEntry?

    var body: some View {
        Text(makeAttributedString())
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "wiki",
                      let id = url.host,
                      let entry = wikiEntries.first(where: { $0.id == id })
                else { return .systemAction }
                presentedEntry = entry
                return .handled
            })
            .popover(item: $presentedEntry) { entry in
                WikiEntryPopover(entry: entry)
            }
    }

    private func makeAttributedString() -> AttributedString {
        var result = AttributedString(text)
        guard !wikiEntries.isEmpty else { return result }

        // Sort descending by title length so longer matches (e.g. "Spell Slots") win over substrings (e.g. "Spell")
        let sorted = wikiEntries.sorted { $0.title.count > $1.title.count }

        for entry in sorted {
            guard let url = URL(string: "wiki://\(entry.id)") else { continue }
            var searchFrom = text.startIndex

            while searchFrom < text.endIndex {
                guard let range = text.range(
                    of: entry.title,
                    options: [.caseInsensitive],
                    range: searchFrom..<text.endIndex
                ) else { break }

                let prefixCount = text.distance(from: text.startIndex, to: range.lowerBound)
                let matchCount = text.distance(from: range.lowerBound, to: range.upperBound)

                let lo = result.characters.index(result.startIndex, offsetBy: prefixCount)
                let hi = result.characters.index(lo, offsetBy: matchCount)

                // Only link if this range isn't already linked by a longer match
                let alreadyLinked = result[lo..<hi].runs.contains { $0.link != nil }
                if !alreadyLinked {
                    result[lo..<hi].link = url
                }

                searchFrom = range.upperBound
            }
        }

        return result
    }
}

// MARK: - Popover Content

private struct WikiEntryPopover: View {
    let entry: WikiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.title)
                .font(.headline)
            Divider()
            Text(entry.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(minWidth: 240, maxWidth: 360)
    }
}
