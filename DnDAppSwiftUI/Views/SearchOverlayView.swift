import SwiftUI

struct SearchOverlayView: View {
    @Bindable var viewModel: CampaignViewModel
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.isSearchPresented = false
                    }
                }

            VStack(spacing: 16) {
                // Capsule search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 17, weight: .semibold))

                    TextField("Search monsters, NPCs, characters, wiki...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($isSearchFieldFocused)

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            viewModel.searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .clipShape(Capsule())

                // Results
                if !viewModel.searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(viewModel.searchResults) { result in
                                SearchResultRow(result: result) {
                                    viewModel.selectSidebarItem(result.sidebarID)
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.isSearchPresented = false
                                    }
                                    viewModel.searchQuery = ""
                                }
                            }
                        }
                        .padding(6)
                    }
                    .frame(minWidth: 320, idealWidth: 420, maxWidth: 480, minHeight: 100, idealHeight: 260, maxHeight: 360)
                } else if !viewModel.searchQuery.isEmpty {
                    Text("No results found")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(minWidth: 380, idealWidth: 460, maxWidth: 520, minHeight: 160)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 40, x: 0, y: 20)
        }
        .onAppear {
            isSearchFieldFocused = true
        }
        .onKeyPress(.escape) {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.isSearchPresented = false
            }
            return .handled
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .center)))
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    let result: SearchResult
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: result.systemImage)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(result.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
