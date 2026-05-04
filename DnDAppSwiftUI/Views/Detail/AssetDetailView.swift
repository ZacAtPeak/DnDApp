import SwiftUI

struct AssetDetailView: View {
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(asset.name)
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    Text(asset.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)

                    if asset.isPublic {
                        Label("Public", systemImage: "globe")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else {
                        Label("Private", systemImage: "lock")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    Spacer()
                }
            }

            Divider()

            Text(asset.description)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 16) {
                if let location = asset.location {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(location)
                            .foregroundStyle(.secondary)
                    }
                }

                if let difficulty = asset.difficulty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(difficulty)
                            .foregroundStyle(.secondary)
                    }
                }

                if let rewards = asset.rewards {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rewards")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text(rewards)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
