import SwiftUI

// MARK: - Environment Keys

private struct WikiEntriesKey: EnvironmentKey {
    static let defaultValue: [WikiEntry] = []
}

private struct WikiNavigationKey: EnvironmentKey {
    static let defaultValue: ((WikiEntry) -> Void)? = nil
}

private struct LootNavigationKey: EnvironmentKey {
    static let defaultValue: ((LootItem) -> Void)? = nil
}

private struct SpellNavigationKey: EnvironmentKey {
    static let defaultValue: ((SpellEntry) -> Void)? = nil
}

extension EnvironmentValues {
    var wikiEntries: [WikiEntry] {
        get { self[WikiEntriesKey.self] }
        set { self[WikiEntriesKey.self] = newValue }
    }

    var navigateToWikiEntry: ((WikiEntry) -> Void)? {
        get { self[WikiNavigationKey.self] }
        set { self[WikiNavigationKey.self] = newValue }
    }

    var navigateToLootItem: ((LootItem) -> Void)? {
        get { self[LootNavigationKey.self] }
        set { self[LootNavigationKey.self] = newValue }
    }

    var navigateToSpellEntry: ((SpellEntry) -> Void)? {
        get { self[SpellNavigationKey.self] }
        set { self[SpellNavigationKey.self] = newValue }
    }
}

// MARK: - Token

private struct TextToken: Identifiable {
    let id = UUID()
    let content: String
    let wikiEntry: WikiEntry?
}

// MARK: - WikiLinkedText

struct WikiLinkedText: View {
    let text: String

    @Environment(\.wikiEntries) private var wikiEntries

    var body: some View {
        WikiTokenFlowLayout {
            ForEach(tokens) { token in
                if let entry = token.wikiEntry {
                    WikiLinkToken(content: token.content, entry: entry)
                } else {
                    Text(token.content)
                        .fixedSize()
                }
            }
        }
    }

    private var tokens: [TextToken] {
        tokenize(text: text, entries: wikiEntries)
    }

    private func tokenize(text: String, entries: [WikiEntry]) -> [TextToken] {
        guard !entries.isEmpty else { return wordTokens(from: text) }

        // Build a flat list of (term, entry) pairs from both titles and aliases,
        // sorted longest-first so "Spell Slots" wins over a hypothetical shorter overlap.
        let allTerms: [(term: String, entry: WikiEntry)] = entries
            .flatMap { entry in ([entry.title] + entry.aliases).map { (term: $0, entry: entry) } }
            .sorted { $0.term.count > $1.term.count }

        var matches: [(range: Range<String.Index>, entry: WikiEntry)] = []
        for (term, entry) in allTerms {
            var searchFrom = text.startIndex
            while searchFrom < text.endIndex {
                guard let range = text.range(
                    of: term, options: .caseInsensitive,
                    range: searchFrom..<text.endIndex
                ) else { break }
                if !matches.contains(where: { $0.range.overlaps(range) }) {
                    matches.append((range, entry))
                }
                searchFrom = range.upperBound
            }
        }
        matches.sort { $0.range.lowerBound < $1.range.lowerBound }

        var tokens: [TextToken] = []
        var cursor = text.startIndex
        for match in matches {
            if cursor < match.range.lowerBound {
                tokens += wordTokens(from: String(text[cursor..<match.range.lowerBound]))
            }
            tokens.append(TextToken(content: String(text[match.range]), wikiEntry: match.entry))
            cursor = match.range.upperBound
        }
        if cursor < text.endIndex {
            tokens += wordTokens(from: String(text[cursor...]))
        }
        return tokens
    }

    // Splits plain text into word-sized tokens so the flow layout can wrap at word boundaries.
    private func wordTokens(from plainText: String) -> [TextToken] {
        guard !plainText.isEmpty else { return [] }
        var tokens: [TextToken] = []
        var remaining = Substring(plainText)
        while !remaining.isEmpty {
            if let sep = remaining.firstIndex(where: { $0 == " " || $0 == "\n" }) {
                let next = remaining.index(after: sep)
                tokens.append(TextToken(content: String(remaining[..<next]), wikiEntry: nil))
                remaining = remaining[next...]
            } else {
                tokens.append(TextToken(content: String(remaining), wikiEntry: nil))
                break
            }
        }
        return tokens
    }
}

// MARK: - Wiki Link Token

private struct WikiLinkToken: View {
    let content: String
    let entry: WikiEntry

    @State private var isPresented = false
    @Environment(\.navigateToWikiEntry) private var navigateToWikiEntry

    var body: some View {
        Text(content)
            .underline()
            .foregroundStyle(.tint)
            .fixedSize()
            // Double-tap is added first (inner) so SwiftUI tries it before the single-tap.
            .onTapGesture(count: 2) {
                isPresented = false
                navigateToWikiEntry?(entry)
            }
            .onTapGesture(count: 1) {
                isPresented = true
            }
            .popover(isPresented: $isPresented) {
                WikiEntryPopover(entry: entry)
            }
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

// MARK: - Flow Layout

private struct WikiTokenFlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews).totalSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(in: bounds.width, subviews: subviews)
        for (i, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(x: bounds.minX + result.positions[i].x, y: bounds.minY + result.positions[i].y),
                anchor: .topLeading,
                proposal: .unspecified
            )
        }
    }

    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> (positions: [CGPoint], totalSize: CGSize) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var positions = [CGPoint](repeating: .zero, count: sizes.count)

        // Group indices into lines by wrapping at maxWidth
        var lineRanges: [Range<Int>] = []
        var lineStart = 0
        var lineX: CGFloat = 0
        for i in sizes.indices {
            if lineX + sizes[i].width > maxWidth, lineStart < i {
                lineRanges.append(lineStart..<i)
                lineStart = i
                lineX = 0
            }
            lineX += sizes[i].width
        }
        lineRanges.append(lineStart..<sizes.count)

        // Assign positions row by row
        var y: CGFloat = 0
        for range in lineRanges {
            let lineHeight = range.map { sizes[$0].height }.max() ?? 0
            var x: CGFloat = 0
            for i in range {
                positions[i] = CGPoint(x: x, y: y)
                x += sizes[i].width
            }
            y += lineHeight
        }

        return (positions, CGSize(width: maxWidth, height: y))
    }
}
