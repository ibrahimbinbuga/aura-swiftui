import SwiftUI

struct HistoryView: View {
    let store: MoodStore
    let ns: Namespace.ID
    @Binding var anchor: UUID?
    let onSelect: (MoodEntry) -> Void
    let onNew: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("geçmiş")
                    .font(.system(size: 34, weight: .thin, design: .rounded))
                    #if DEBUG
                    .onLongPressGesture { store.seed() }   // uzun bas: örnek veri
                    #endif
                Spacer()
                Button("yeni", action: onNew)
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            if store.entries.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Text("henüz kayıt yok")
                        .font(.system(.title3, design: .rounded, weight: .light))
                    Text("ilk ruh halini kaydet")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: -48) {
                        ForEach(Array(store.entries.enumerated()), id: \.element.id) { index, entry in
                            Button { onSelect(entry) } label: {
                                MoodCard(entry: entry, ns: ns)
                            }
                            .buttonStyle(.plain)
                            .zIndex(Double(store.entries.count - index))
                            .scrollTransition(.interactive) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                    .opacity(phase.isIdentity ? 1 : 0.6)
                                    .offset(y: phase.value * 20)
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 48)
                }
                .scrollPosition(id: $anchor)
            }
        }
        .foregroundStyle(.white)
        .background(alignment: .top) {
            if let top = store.entries.first {
                RadialGradient(colors: [top.mood.color().opacity(0.4), .clear],
                               center: .top, startRadius: 0, endRadius: 520)
                    .ignoresSafeArea()
            }
        }
    }
}
