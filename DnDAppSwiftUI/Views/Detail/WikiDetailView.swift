import SwiftUI

struct WikiDetailView: View {
    let entry: WikiEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(entry.title)
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            Text(entry.description)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
