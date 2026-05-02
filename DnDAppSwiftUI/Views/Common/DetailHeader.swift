import SwiftUI

struct DetailHeader: View {
    let title: String
    let subtitle: String
    let hpText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(hpText)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
