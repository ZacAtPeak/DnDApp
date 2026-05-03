import SwiftUI

struct InitiativeCard: View {
    @Binding var combatent: Combatent
    var isSelected: Bool
    var onSelect: () -> Void
    var onEdit: () -> Void
    var onRemove: () -> Void
    var onMakeTurn: () -> Void
    var onStatusDrop: ([String]) -> Bool
    @State private var isStatusTargeted = false
    @State private var isFlipped = false

    private var activeStatuses: [StatusCondition] {
        combatent.status ?? []
    }

    private var isDefeated: Bool {
        !combatent.isLairAction && combatent.currentHP == 0
    }

    private var healthRatio: CGFloat {
        guard combatent.maxHP > 0 else { return 0 }
        return min(max(CGFloat(combatent.currentHP) / CGFloat(combatent.maxHP), 0), 1)
    }

    private var temporaryHealthRatio: CGFloat {
        guard combatent.maxHP > 0 else { return 0 }
        return min(max(CGFloat(combatent.temporaryHP) / CGFloat(combatent.maxHP), 0), 1)
    }

    private var healthBarColor: Color {
        if healthRatio > 0 && healthRatio < 0.1 {
            return .red
        }
        return .green
    }

    private var healthText: String {
        if combatent.temporaryHP > 0 {
            return "\(combatent.currentHP)+\(combatent.temporaryHP)/\(combatent.maxHP)"
        }
        return "\(combatent.currentHP)/\(combatent.maxHP)"
    }

    var body: some View {
        ZStack {
            frontView
                .opacity(isFlipped ? 0 : 1)
                .scaleEffect(isFlipped ? 0.9 : 1)
                .allowsHitTesting(!isFlipped)
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFlipped = true
                    }
                }
                .onTapGesture {
                    onSelect()
                }
                .onLongPressGesture {
                    onEdit()
                }

            backView
                .opacity(isFlipped ? 1 : 0)
                .scaleEffect(isFlipped ? 1 : 0.9)
                .allowsHitTesting(isFlipped)
        }
        .grayscale(isDefeated ? 1 : 0)
        .opacity(isDefeated ? 0.55 : 1)
        .animation(.easeInOut(duration: 0.2), value: isFlipped)
        .animation(.easeInOut(duration: 0.2), value: isDefeated)
        .frame(width: 160, alignment: .leading)
        .dropDestination(for: String.self) { payloads, _ in
            onStatusDrop(payloads)
        } isTargeted: { targeted in
            isStatusTargeted = targeted
        }
        .contextMenu {
            Button("Make Current Turn") {
                onMakeTurn()
            }
            Button("Edit") {
                onEdit()
            }
            Button("Remove from Initiative", role: .destructive) {
                onRemove()
            }
        }
        .help("Double-click to quick-edit HP and spell slots. Tap the X to flip back. Long press or secondary-click to edit.")
    }

    // MARK: - Front

    private var frontView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(combatent.name)
                        .font(.headline)
                        .fontWeight(.bold)

                    if let creatureType = combatent.creatureType {
                        Text(creatureType)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text("\(Int(combatent.initiative))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            if !combatent.isLairAction {
                healthBar
            }

            if !combatent.spellSlots.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(combatent.spellSlots, id: \.level) { slot in
                        if slot.max > 0 {
                            HStack(spacing: 2) {
                                ForEach(0..<slot.available, id: \.self) { _ in
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 7))
                                }
                                let used = slot.max - slot.available
                                if used > 0 {
                                    ForEach(0..<used, id: \.self) { _ in
                                        Image(systemName: "circle")
                                            .font(.system(size: 7))
                                    }
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.secondary)
            }

            if !activeStatuses.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Statuses")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(activeStatuses, id: \.name) { status in
                        Text(status.name)
                            .font(.footnote)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: isSelected || combatent.isTurn ? 2 : 1)
        }
        .overlay {
            if isStatusTargeted {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .overlay(alignment: .topLeading) {
            if combatent.isTurn {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
                    .padding([.top, .leading], 10)
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var healthBar: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let healthWidth = width * healthRatio
            let temporaryWidth = width * temporaryHealthRatio
            let temporaryOffset = min(healthWidth, max(width - temporaryWidth, 0))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.16))

                Rectangle()
                    .fill(healthBarColor)
                    .frame(width: healthWidth)

                if combatent.temporaryHP > 0 {
                    Rectangle()
                        .fill(Color.green.opacity(0.45))
                        .frame(width: temporaryWidth)
                        .offset(x: temporaryOffset)
                }

                Text(healthText)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.45), radius: 1, y: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
            }
            .clipShape(Capsule())
        }
        .frame(height: 22)
    }

    // MARK: - Back

    private var backView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFlipped = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()
            }

            Text(combatent.name)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)

            if !combatent.isLairAction {
                HStack(spacing: 4) {
                    Text("HP")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        combatent.currentHP = max(0, combatent.currentHP - 1)
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)

                    Text("\(combatent.currentHP)/\(combatent.maxHP)")
                        .font(.caption2)
                        .monospacedDigit()

                    Button {
                        combatent.currentHP = min(combatent.maxHP, combatent.currentHP + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 4) {
                    Text("Temp")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        combatent.temporaryHP = max(0, combatent.temporaryHP - 1)
                    } label: {
                        Image(systemName: "minus.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)

                    Text("\(combatent.temporaryHP)")
                        .font(.caption2)
                        .monospacedDigit()

                    Button {
                        combatent.temporaryHP = min(999, combatent.temporaryHP + 1)
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !combatent.spellSlots.isEmpty {
                ForEach(combatent.spellSlots.indices, id: \.self) { index in
                    if combatent.spellSlots[index].max > 0 {
                        HStack(spacing: 4) {
                            Text("L\(combatent.spellSlots[index].level)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button {
                                combatent.spellSlots[index].available = max(0, combatent.spellSlots[index].available - 1)
                            } label: {
                                Image(systemName: "minus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)

                            Text("\(combatent.spellSlots[index].available)/\(combatent.spellSlots[index].max)")
                                .font(.caption2)
                                .monospacedDigit()

                            Button {
                                combatent.spellSlots[index].available = min(combatent.spellSlots[index].max, combatent.spellSlots[index].available + 1)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                Text("No spell slots")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(width: 160, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: isSelected || combatent.isTurn ? 2 : 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }

    private var cardStrokeColor: Color {
        if isSelected {
            return .accentColor
        }
        if combatent.isLairAction {
            return .purple.opacity(0.6)
        }
        return combatent.isTurn ? .orange : Color.secondary.opacity(0.2)
    }
}
