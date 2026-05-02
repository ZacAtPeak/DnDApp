import SwiftUI

struct SpellSlotsView: View {
    let slots: [SpellSlot]
    let encounterSlotCount: Int?

    var body: some View {
        DetailSection(title: "Spell Slots") {
            if let encounterSlotCount {
                HStack {
                    Text("Remaining")
                    Spacer()
                    Text("\(encounterSlotCount)")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 4)
            } else if slots.isEmpty {
                Text("No spell slots")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(slots, id: \.level) { slot in
                    HStack {
                        Text("Level \(slot.level)")
                        Spacer()
                        Text("\(slot.count)")
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
