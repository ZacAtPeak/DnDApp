import SwiftUI

struct RollHistoryInspectorView: View {
    @Bindable var viewModel: CampaignViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Roll History")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.rollHistory.count) rolls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

            Divider()

            if viewModel.rollHistory.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "dice")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("No rolls yet")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(viewModel.rollHistory) { entry in
                            RollHistoryRow(entry: entry)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .listStyle(.plain)
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

            HStack(spacing: 4) {
                Text("\(entry.roll)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                if entry.modifier != 0 {
                    Text(entry.modifier >= 0 ? "+\(entry.modifier)" : "\(entry.modifier)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(entry.modifier >= 0 ? .green : .red)
                }
            }

            Text("\(Int(entry.total))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .frame(minWidth: 28, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
