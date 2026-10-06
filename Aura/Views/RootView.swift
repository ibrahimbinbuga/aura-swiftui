import SwiftUI

struct RootView: View {
    enum Screen: Equatable { case picker, history, detail(UUID) }

    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var store = MoodStore()
    @State private var screen: Screen = .picker
    @State private var pendingID = UUID()
    @State private var historyAnchor: UUID?
    @Namespace private var ns

    private let spring = Animation.spring(response: 0.6, dampingFraction: 0.82)

    var body: some View {
        ZStack {
            Color(red: 11/255, green: 11/255, blue: 16/255).ignoresSafeArea()

            if !hasOnboarded {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) { hasOnboarded = true }
                }
                .transition(.opacity)
            } else {
                switch screen {
                case .picker:
                    MoodPickerView(ns: ns, blobID: pendingID,
                                   hasHistory: !store.entries.isEmpty,
                                   onSave: { mood in
                                       store.add(mood, id: pendingID)
                                       historyAnchor = nil
                                       withAnimation(spring) { screen = .history }
                                   },
                                   onHistory: { withAnimation(spring) { screen = .history } })

                case .history:
                    HistoryView(store: store, ns: ns, anchor: $historyAnchor,
                                onSelect: { entry in
                                    withAnimation(spring) { screen = .detail(entry.id) }
                                },
                                onNew: {
                                    pendingID = UUID()
                                    withAnimation(spring) { screen = .picker }
                                })

                case .detail(let id):
                    if let entry = store.entries.first(where: { $0.id == id }) {
                        DetailView(entry: entry,
                                   week: store.week(endingAt: entry.date),
                                   ns: ns,
                                   onBack: { withAnimation(spring) { screen = .history } })
                    }
                }
            }
        }
    }
}
