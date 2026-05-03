import SwiftUI

struct SkillsView: View {
    let skills: [SkillProficiency]
    var onRoll: ((String, Int) -> Void)?

    var body: some View {
        DetailSection(title: "Skills") {
            if skills.isEmpty {
                Text("No skills")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(skills.indices, id: \.self) { index in
                        let row = SkillRow(skill: skills[index])
                        if let onRoll {
                            Button {
                                onRoll(skills[index].skill, skills[index].bonus)
                            } label: {
                                row
                            }
                            .buttonStyle(.plain)
                        } else {
                            row
                        }
                    }
                }
            }
        }
    }
}

private struct SkillRow: View {
    let skill: SkillProficiency

    var body: some View {
        HStack(spacing: 6) {
            Text(skill.skill)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)

            Spacer(minLength: 4)

            if skill.isProficient {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.accentColor)
            }

            Text(skill.abilityScore.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(minWidth: 28, alignment: .trailing)

            Text(formatBonus(skill.bonus))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .frame(minWidth: 28, alignment: .trailing)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func formatBonus(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }
}
