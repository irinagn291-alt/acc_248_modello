import SwiftUI

/// Role: pill CTA for Install. Accent is the live verb only.
struct StudioPillStyle: ButtonStyle {
    var isLoading: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioType.title)
            .foregroundStyle(isEnabled ? StudioInk.surface : StudioInk.muted)
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, StudioSpace.sm)
            .background(isEnabled ? StudioInk.accent : StudioInk.surface)
            .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous)
                    .stroke(StudioInk.muted.opacity(isEnabled ? 0 : 0.35), lineWidth: 1)
            }
            .opacity(isLoading ? 0.7 : (configuration.isPressed ? 0.88 : 1))
            .scaleEffect(scale(configuration.isPressed))
            .animation(StudioMotion.ease(reduceMotion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }

    private func scale(_ pressed: Bool) -> CGFloat {
        if reduceMotion { return 1 }
        return pressed ? StudioMotion.pressScale : 1
    }
}

/// Role: flat chip used for chrome that is not the live verb.
struct StudioChipStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioType.callout)
            .foregroundStyle(isEnabled ? StudioInk.ink : StudioInk.muted)
            .frame(minHeight: 44)
            .padding(.horizontal, StudioSpace.sm)
            .background(StudioInk.surface)
            .clipShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? StudioMotion.pressScale : 1))
            .animation(StudioMotion.ease(reduceMotion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
    }
}

/// Role: destructive confirm. Does not wear accent.
struct StudioResetStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StudioType.title)
            .foregroundStyle(isEnabled ? StudioInk.ink : StudioInk.muted)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(StudioInk.surface)
            .clipShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? StudioMotion.pressScale : 1))
            .animation(StudioMotion.ease(reduceMotion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: StudioRadius.card, style: .continuous))
    }
}

/// Role: unlabeled trial tile on the Quiz rail.
struct StudioTrialStyle: ButtonStyle {
    var cooled: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(tileOpacity(configuration.isPressed))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? StudioMotion.pressScale : 1))
            .animation(StudioMotion.ease(reduceMotion), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: StudioRadius.chip, style: .continuous))
    }

    private func tileOpacity(_ pressed: Bool) -> Double {
        if !isEnabled || cooled { return 0.45 }
        return pressed ? 0.8 : 1
    }
}
