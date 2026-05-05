import SwiftUI

struct RollHistoryInspectorView: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Roll History")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.rollHistory.count) rolls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    viewModel.saveRollHistory()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.rollHistory.isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                .disabled(viewModel.rollHistory.isEmpty)

                Button {
                    viewModel.clearRollHistory()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.rollHistory.isEmpty ? Color.secondary.opacity(0.3) : Color.red)
                .disabled(viewModel.rollHistory.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()
                .opacity(0.4)

            if viewModel.rollHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "dice")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text("No rolls yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(viewModel.rollHistory) { entry in
                                RollHistoryRow(entry: entry)
                            }
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: viewModel.rollHistory.count) {
                        withAnimation {
                            proxy.scrollTo("bottom")
                        }
                    }
                }
            }
        }
        .frame(minWidth: 220, idealWidth: 260)
    }
}

private struct RollHistoryRow: View {
    let entry: RollEntry

    private var criticalStatus: CriticalStatus {
        if entry.roll == 20 { return .success }
        if entry.roll == 1 { return .failure }
        return .normal
    }

    private var totalColor: Color {
        switch criticalStatus {
        case .success: return .green
        case .failure: return .red
        case .normal:  return .primary
        }
    }

    private var backgroundColor: Color? {
        switch criticalStatus {
        case .success: return .green
        case .failure: return .red
        case .normal: return nil
        }
    }

    enum CriticalStatus {
        case success, failure, normal
    }

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(entry.type)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Text("•")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary.opacity(0.5))

                    Text(entry.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary.opacity(0.7))
                }
            }

            Spacer(minLength: 8)

            // Roll + modifier
            if entry.modifier != 0 {
                HStack(spacing: 2) {
                    Text("\(entry.roll)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(entry.modifier >= 0 ? "+\(entry.modifier)" : "\(entry.modifier)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(entry.modifier >= 0 ? .green : .red)
                }
            }

            // Total badge
            Text("\(Int(entry.total))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(totalColor)
                .frame(minWidth: 30)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(totalColor.opacity(0.25), lineWidth: 1)
                }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background {
            if let bgColor = backgroundColor {
                bgColor.opacity(0.15)
            } else {
                Color(nsColor: .controlBackgroundColor).opacity(0.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke((backgroundColor ?? Color.primary).opacity(0.07), lineWidth: 1)
        }
    }
}
