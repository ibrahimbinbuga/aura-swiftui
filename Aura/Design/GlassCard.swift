import SwiftUI

private struct GlassCard: ViewModifier {
    let tint: Color
    let interactive: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        if #available(iOS 26, *) {
            content.glassEffect(.regular.tint(tint.opacity(0.18)).interactive(interactive), in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(.white.opacity(0.12), lineWidth: 1))
        }
    }
}

extension View {
    func glassCard(tint: Color, interactive: Bool = false) -> some View {
        modifier(GlassCard(tint: tint, interactive: interactive))
    }
}
