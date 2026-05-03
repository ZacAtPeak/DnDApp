import SwiftUI

struct SpellSlotsView: View {
    let slots: [SpellSlot]

    private var normalizedSlots: [SpellSlot] {
        slots.normalizedToLevel9()
    }

    var body: some View {
        DetailSection(title: "Spell Slots") {
            if normalizedSlots.isEmpty || normalizedSlots.allSatisfy({ $0.max == 0 }) {
                Text("No spell slots")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(normalizedSlots, id: \.level) { slot in
                        if slot.max > 0 {
                            HStack(spacing: 6) {
                                Text(slot.level.romanNumeral)
                                    .font(.system(size: 11, weight: .semibold, design: .serif))
                                    .foregroundStyle(.secondary)
                                    .frame(minWidth: 20, alignment: .leading)

                                HStack(spacing: 4) {
                                    ForEach(0..<slot.available, id: \.self) { _ in
                                        Image(systemName: "circle.fill")
                                            .font(.caption2)
                                    }
                                    let used = slot.max - slot.available
                                    if used > 0 {
                                        ForEach(0..<used, id: \.self) { _ in
                                            Image(systemName: "circle")
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
